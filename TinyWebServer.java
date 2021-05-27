/*
 * Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

import java.io.*;
import java.net.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.function.*;
import com.sun.net.httpserver.*;


public class TinyWebServer
    implements HttpHandler
{

    private static final int DEFAULT_PORT = 8081;
    private static Path ROOT = Path.of("/");

    private Path dir;
    private boolean log;

    private TinyWebServer(Path dir, boolean log) {
        this.dir = dir;
        this.log = log;
    }

    private static void wr(OutputStream out, String fmt, Object ... args)
        throws IOException
    {
        out.write(String.format(fmt, args).getBytes("UTF-8"));
    }

    private static void wr(Writer out, String fmt, Object ... args)
        throws IOException
    {
        out.write(String.format(fmt, args));
    }

    private static final String UTF8 = "; charset=utf-8";
    private static final String TEXT_HTML = "text/html" + UTF8;

    private static String contentType(Path p) {
        var ext = "html";
        var n = p.getFileName().toString();
        var i = n.lastIndexOf(".");
        if (i >= 0)
            ext = n.substring(i + 1);
        return switch (ext) {
            case "css" -> "text/css" + UTF8;
            case "gif" -> "image/gif";
            case "ico" -> "image/x-icon";
            case "html" -> TEXT_HTML;
            case "jpg" -> "image/jpeg";
            case "pdf" -> "application/pdf";
            case "png" -> "image/png";
            case "svg" -> "image/svg+xml";
            default ->
                throw new IllegalArgumentException("Unknown file extension: "
                                                   + ext);
        };
    }

    private void log(String fmt, Object ... args) {
        if (log)
            System.err.format(fmt + "%n", args);
    }

    private static enum Status {

        OK(200),
        Moved_Permanently(301),
        Forbidden(403),
        Not_Found(404),
        Internal_Server_Error(500);

        private int code;

        private Status(int code) { this.code = code; }

        public String toString() {
            return name().replace('_', ' ');
        }

    }

    @FunctionalInterface
    private static interface TransferAgent {
        void transferTo(OutputStream out) throws IOException;
    }

    private static record Response(Status status,
                                   Consumer<Headers> headerSetter,
                                   long contentLength,
                                   TransferAgent transferAgent,
                                   AutoCloseable closer)
        implements AutoCloseable
    {

        Response(Status s, Consumer<Headers> hs, long cl, TransferAgent ta) {
            this(s, hs, cl, ta, () -> { });
        }

        Response(Status s, Consumer<Headers> hs, long cl) {
            this(s, hs, cl, out -> { });
        }

        public void close() throws IOException {
            try {
                closer.close();
            } catch (IOException x) {
                throw x;
            } catch (Exception x) {
                throw new InternalError(x);
            }
        }

    }

    private Response send(HttpExchange hx, Path path)
        throws IOException
    {
        var ct = contentType(path);
        var in = Files.newInputStream(path);
        return new Response(Status.OK,
                            hds -> { hds.set("Content-Type", ct); },
                            Files.size(path),
                            out -> in.transferTo(out),
                            in);
    }

    private Response redirect(HttpExchange hx, String to)
        throws IOException
    {
        return new Response(Status.Moved_Permanently,
                            hds -> { hds.set("Location", to); },
                            -1);
    }

    private Response listDirectory(HttpExchange hx, Path path)
        throws IOException
    {

        var uri = hx.getRequestURI();
        var out = new CharArrayWriter();
        wr(out, "<h2>%s</h2>", uri.getPath());
        wr(out, "<a href='/'><i>root</i></a><br>");
        wr(out, "<a href='..'><i>parent</i></a><br>");
        wr(out, "<br><b>here</b><br>");
        var dirs = new ArrayList<Path>();
        for (Path p : Files.list(path).sorted().toList()) {
            var pn = p.getFileName().toString();
            if (Files.isDirectory(p)) {
                pn = pn + "/";
                dirs.add(p);
            }
            wr(out, "<a href='%s'>%s</a><br>", pn, pn);
        }
        wr(out, "<br><b>below</b><br>");
        for (Path d : dirs) {
            for (Path p : Files.walk(d).sorted().toList()) {
                var pr = path.relativize(p);
                if (pr.getNameCount() < 2)
                    continue;
                var pn = pr.toString();
                if (Files.isDirectory(p))
                    pn = pn + "/";
                wr(out, "<a href='%s'>%s</a><br>", pn, pn);
            }
        }
        var bytes = out.toString().getBytes("UTF-8");

        return new Response(Status.OK,
                            hds -> { hds.set("Content-Type", TEXT_HTML); },
                            bytes.length,
                            rout -> rout.write(bytes));

    }

    private Response error(HttpExchange hx, Status status)
        throws IOException
    {

        var out = new CharArrayWriter();
        wr(out, "<h2>%d %s</h2>", status.code, status);
        var bytes = out.toString().getBytes("UTF-8");

        return new Response(status,
                            hds -> { hds.set("Content-Type", TEXT_HTML); },
                            bytes.length,
                            rout -> rout.write(bytes));

    }

    private Response respond(HttpExchange hx, Path path)
        throws IOException
    {
        var uri = hx.getRequestURI();
        try {
            if (Files.isDirectory(path)) {
                var idx = path.resolve("_index");
                if (Files.isRegularFile(idx))
                    return send(hx, idx);
                if (!uri.getPath().endsWith("/"))
                    return redirect(hx, uri.toString() + "/");
                return listDirectory(hx, path);
            }
            if (Files.isSymbolicLink(path))
                return error(hx, Status.Forbidden);
            return send(hx, path);
        } catch (NoSuchFileException x) {
            return error(hx, Status.Not_Found);
        } catch (Exception x) {
            System.err.print("500 Internal Server Error: ");
            x.printStackTrace();
            return error(hx, Status.Internal_Server_Error);
        }
    }

    public void handle(HttpExchange hx) throws IOException {
        var uri = hx.getRequestURI();
        var path = dir.resolve(ROOT.relativize(Path.of(uri.getPath())));
        try (var rsp = respond(hx, path)) {
            log("%s %s: %d %s (%d)",
                hx.getRequestMethod(), uri.getPath(),
                rsp.status().code, rsp.status(),
                rsp.contentLength());
            long len = (hx.getRequestMethod().equals("HEAD")
                        ? -1 : rsp.contentLength());
            var hds = hx.getResponseHeaders();
            rsp.headerSetter().accept(hds);
            if (len >= 0)
                hds.set("Content-Length", Long.toString(len));
            hx.sendResponseHeaders(rsp.status().code, len);
            if (len >= 0) {
                try (var out = hx.getResponseBody()) {
                    rsp.transferAgent().transferTo(out);
                }
            }
        } catch (Exception x) {
            System.err.print("Unhandled exception: ");
            x.printStackTrace();
        } finally {
            hx.close();
        }
    }

    public static void main(String ... args) throws IOException {
        Path dir = null;
        Integer port = null;
        boolean log = false;
        for (var s : args) {
            if (s.equals("-v"))
                log = true;
            else if (s.startsWith("-"))
                throw new IllegalArgumentException(s);
            else if (dir == null)
                dir = Path.of(s);
            else if (port == null)
                port = Integer.valueOf(s);
            else
                throw new IllegalArgumentException(s);
        }
        if (port == null)
            port = DEFAULT_PORT;
        var server = HttpServer.create(new InetSocketAddress(port), 0);
        System.out.format("Serving %s on localhost:%d%n", dir, port);
        server.createContext("/", new TinyWebServer(dir, log));
        server.setExecutor(Executors.newCachedThreadPool());
        server.start();
    }

}
