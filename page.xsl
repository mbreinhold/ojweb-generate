<?xml version="1.0" encoding="utf-8"?>

<!--
  Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.

  This code is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License version 2 only, as
  published by the Free Software Foundation.  Oracle designates this
  particular file as subject to the "Classpath" exception as provided
  by Oracle in the LICENSE file that accompanied this code.

  This code is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  version 2 for more details (a copy is included in the LICENSE file that
  accompanied this code).

  You should have received a copy of the GNU General Public License version
  2 along with this work; if not, write to the Free Software Foundation,
  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.

  Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
  or visit www.oracle.com if you need additional information or have any
  questions.
  -->

<!DOCTYPE s:stylesheet [
  <!ENTITY copy "&#xa9;">
  <!ENTITY dot "&#xb7;">
  <!ENTITY quad "&#x2001;">
  <!ENTITY qquad "&quad;&quad;">
]>

<s:stylesheet xmlns:s="http://www.w3.org/1999/XSL/Transform"
              xmlns:h="http://www.w3.org/1999/xhtml"
              xmlns="http://www.w3.org/1999/xhtml"
              version="1.0"
              exclude-result-prefixes="h">

<s:output method="html"
  indent="no"
  encoding="utf-8"
  doctype-system="html"/>

<s:template match="@*|node()">
  <s:copy>
    <s:apply-templates select="@*|node()"/>
  </s:copy>
</s:template>

<!-- Serried H4 headers -->

<s:template match="h:section/h:h4[following-sibling::*[1][name()='p']
                                  and not(../preceding-sibling::*[1][name()='h1'])]">
  <p class="br">
    <b><s:copy-of select="*|text()"/></b>
    <s:text>&qquad;</s:text>
    <s:copy-of select="following-sibling::*[1][name()='p']/node()"/>
  </p>
</s:template>

<s:template match="h:p[preceding-sibling::*[1][name()='h4']
                       and not(../preceding-sibling::*[1][name()='h1'])]"/>

<!-- Main -->

<s:template match="/h:html">
  <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/>
      <title>
        <s:value-of select="h:body/h:section[1]/h:h1[1]"/>
        <s:if test="h:body/h:section/h:section[@class='level2 subtitle']">
          <s:text>: </s:text>
          <s:value-of select="h:body/h:section/h:section[@class='level2 subtitle']/h:h2"/>
        </s:if>
      </title>
      <link rel="shortcut icon" href="/images/nanoduke.ico"/>
      <link rel="stylesheet" type="text/css" href="/page-serif.css"/>
    </head>
    <body>
      <article>
        <s:apply-templates select="h:body/h:section/*"/>
        <footer class="legal">
          <div>&copy; <s:value-of select="$year"/> Oracle Corporation and/or its affiliates</div>
          <div><a href="/tou">Terms of Use</a>
          &dot; License: <a href="https://openjdk.java.net/legal/gplv2+ce.html">GPLv2</a>
          &dot; <a href="https://www.oracle.com/legal/privacy/index.html">Privacy</a>
          &dot; <a href="https://www.oracle.com/legal/trademarks.html">Trademarks</a></div>
          <div> <s:value-of select="$hash"/> &dot; <s:value-of select="$time"/></div>
        </footer>
      </article>
    </body>
  </html>
</s:template>

</s:stylesheet>
