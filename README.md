
OpenJDK Web Page Generator
==========================

The `Makefile` in this repository generates HTML files and other assets
for a subtree of the `openjdk.java.net` web site.

To use it to preview a local clone of a subtree repository, clone this
repository into your local repository and then run its `Makefile`:

    $ cd <subtree-repo>
    $ git clone <URL>/ojweb-generate.git
    $ make -f ojweb-generate/Makefile

It will generate docs into `$BUILD`, or into `./build` if the `BUILD`
environment variable is not set.

This repository includes a tiny web server which you can use to preview
the generated files locally:

    $ make -f ojweb-generate/Makefile preview

Then point your browser at `http://localhost:8081/`.

### Tools required

You’ll need Git, Tidy, GNU Make, xsltproc, and [Pandoc] (version 2.5 or
later), plus the usual core utilities.

To install these on a Debian-based system:

    $ apt-get install git tidy make xsltproc pandoc

To install these on macOS using [Homebrew]:

    $ brew install git tidy-html5 pandoc
    $ export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"


Source format
-------------

We use [Pandoc] to generate HTML from Markdown (`.md`) source files in
Pandoc’s [extended version of Markdown][pd-markdown] which includes,
among other things, [header attributes][pd-hd-attr] and several types of
[tables][pd-tables].


### Title and metadata

For the consistent appearance of all pages, the first lines of a Markdown
source file should be of the form

    # Off the Shoulders of Orion
    ## I’ve Seen Things You Wouldn’t Believe {.subtitle}

    #### Roy Batty {.author}
    #### January 2019 {.date}

The header attributes `{.subtitle}`, `{.author}`, and `{.date}` identify
the corresponding headers as containing metadata.  The subtitle is
optional.  Blank lines between these elements are ignored.


### Table of contents

To include a simple, two-level table of contents (TOC) at the top of your
document, include this line right after the final header line:

    <div class="table-of-contents"/>

(We should use a `nav` element here, but Tidy mistakenly treats `nav`s as
inline elements and so wraps them in `p` elements, which is not helpful,
so we use a `div` instead.)

To omit a section and all of its subsections from the TOC, annotate the
section’s header with `{toc=omit}`.  To omit all of the subsections of a
section but not the section itself, annotate the section’s header with
`{toc=omit-children}`.  For example:

    ## Style Guidelines for Text Blocks {toc=omit-children}


### Optional `head` content

If a document `foo.md` requires a custom CSS stylesheet, or some
JavaScript code, then place that content in a sibling `foo.head` file,
wrapped in a `head` element:

    <head>
      <style>
        CODE { color: red; }
      </style>
      <script>
        document.addEventListener("DOMContentLoaded",
                                  (event) => alert("Hi!"));
      </script>
    </head>

The children of the `head` element in this file will be copied to the end
of the `head` element in the generated HTML.

Please avoid using optional `head` content unless absolutely
necessary. CSS rules introduced in this way can interfere with the
default stylesheet and JavaScript, of course, comes with its own set of
risks.


[Pandoc]: https://pandoc.org/
[pd-markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown
[pd-tables]: https://pandoc.org/MANUAL.html#tables
[pd-hd-attr]: https://pandoc.org/MANUAL.html#extension-header_attributes
[Homebrew]: https://brew.sh
