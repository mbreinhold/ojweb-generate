
OpenJDK Web Page Generator
==========================


The `Makefile` in this repository generates HTML files and other assets
for a subtree of the `openjdk.org` web site.

The easiest way to preview a local documentation repository is to clone
this repository into your local repository and then create a trivial
`Makefile` in that repository:

    $ echo 'include ojweb-generate/Makefile' >Makefile

Then running `make` in your repository will format the source files into
the `./build` directory, or to `$BUILD` if the `BUILD` environment
variable is set.

This repository includes a tiny web server which you can use to preview
the generated files locally:

    $ make preview

Then point your browser at `http://localhost:8081/`.

Additional `make` targets include:

  - `make update` — updates the local `ojweb-generate` repository
  - `make clean` — removes the build
  - `make help` — summarizes the `make` targets


### Tools required

You’ll need GNU Make, Git, Tidy, xsltproc, [Pandoc] (version 2.5 or
later), and Graphviz, plus the usual core utilities.

To install these on a Debian-based Linux system:

    $ apt-get install make git tidy xsltproc pandoc graphviz fonts-dejavu

To install these on macOS using [Homebrew]:

    $ brew install coreutils gnu-sed make git tidy-html5 pandoc graphviz
    $ export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    $ export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    $ export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"


Source format
-------------

We use [Pandoc] to generate HTML from Markdown (`.md`) source files in
Pandoc’s [extended version of Markdown][pd-markdown] which includes,
among other things, support for [header attributes][pd-hd-attr], several
types of [tables][pd-tables], and mathematics.


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

To include a simple, two-level table of contents in your document, place
this line where you’d like the table to appear:

    <div class="table-of-contents"/>

To place a heading before the table, use an `h4` heading:

    #### Contents

    <div class="table-of-contents"/>

(We should use a `nav` element here, but Tidy mistakenly treats `nav`s as
inline elements and so wraps them in `p` elements, which is not helpful,
so we use a `div` instead.)

To omit a section and all of its subsections from the table of contents,
annotate the section’s header with `{toc=omit}`.  To omit all of the
subsections of a section but not the section itself, annotate the
section’s header with `{toc=omit-children}`.  For example:

    ## Style Guidelines for Text Blocks {toc=omit-children}


### Mathematics

[MathJax] is enabled for mathematical expressions using TeX and LaTeX
notation.  Enclose inline mathematics in `\( ... \)`, and enclose
displayed equations in `\[ ... \]`:

    When \(a \ne 0\) there are two solutions to \(ax^2+bx+c=0\),
    which are \[x = {-b \pm\sqrt{b^2-4ac} \over 2a}.\]

The MathJax JavaScript display engine is loaded only when needed.


### Optional `head` content

If a Markdown document `foo.md` requires a custom CSS stylesheet, or some
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

You can customize the formatting process even further by creating a
`Local.gmk` file; please see the `Makefile` for guidance.


### Additional source forms

A file named `_index.md` produces the `index.html` file for the directory
that contains it.

Files ending in `.dot` are processed by the [Graphviz] `dot` tool to
produce corresponding `.svg` files in the output directory.

Files ending in `.html` are copied verbatim to the output directory,
dropping the `.html` suffix.

Files ending in `.jpg`, `.png`, or `.svg` are copied verbatim to the
output directory, preserving their suffixes.


Output format
-------------

Each Markdown or HTML source file, `foo/bar.md` or `foo/bar.html`,
produces an output file `foo/bar`, without the suffix.

The output will contain a subtree map in the `_map` file, from which you
can visit all the pages in the subtree.

The footer of each generated HTML page contains the usual legal notices,
a timestamp, and the hash of the most recent commit of the source file
for that page.  The hash is a link to the history of the source file in
the originating repository.


[Pandoc]: https://pandoc.org/
[pd-markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown
[pd-tables]: https://pandoc.org/MANUAL.html#tables
[pd-hd-attr]: https://pandoc.org/MANUAL.html#extension-header_attributes
[Homebrew]: https://brew.sh
[MathJax]: https://docs.mathjax.org/en/latest/index.html
[Graphviz]: https://graphviz.org/doc/info/lang.html
