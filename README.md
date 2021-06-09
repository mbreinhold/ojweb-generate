
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

You’ll need Git, Tidy, GNU Make, xsltproc, and Pandoc (version 2.5 or
later), plus the usual core utilities.

To install these on a Debian-based system:

    $ apt-get install git tidy make xsltproc pandoc


Source format
-------------

We use [Pandoc] to generate HTML from Markdown (`.md`) source files in
Pandoc’s [extended version of Markdown] which includes, among other
things, [header attributes][pd-hd-attr] and several types of
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
optional.

### Optional `HEAD` content

If a document `foo.md` requires a custom CSS stylesheet, or some
JavaScript code, then place that content in a sibling `foo.head` file,
wrapped in a `HEAD` element:

    <head>
      <style>
        CODE { color: red; }
      </style>
    </head>

The children of the `HEAD` element in this file will be copied to the end
of the `HEAD` element in the generated HTML.

Please avoid using optional `HEAD` content unless absolutely
required. CSS rules introduced in this way can interfere with the default
stylesheet and JavaScript, of course, comes with its own set of risks.


[Pandoc]: https://pandoc.org/
[pd-markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown
[pd-tables]: https://pandoc.org/MANUAL.html#tables
[pd-hd-attr]: https://pandoc.org/MANUAL.html#extension-header_attributes
