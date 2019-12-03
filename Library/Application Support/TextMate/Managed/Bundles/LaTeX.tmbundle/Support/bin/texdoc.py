#!/usr/bin/python
# -*- coding: utf-8 -*-

# -----------------------------------------------------------------------------
# Author: Brad Miller
# -----------------------------------------------------------------------------

"""Display documentation for tex packages.

This script is a hacked together set of heuristics to try and bring some
order out of the various bits and pieces of documentation that are strewn
around any given LaTeX distro.

``texdoctk`` provides a nice list of packages, along with paths to the
documents that are relative to one or more roots. The root for these documents
varies. This script attempts to find the right path to documentation that
really exist on your system and make it easy for you to get to it.

The packages are displayed in two groups:

- The first group is the set of packages that you included in your document.
- The second group is the set of packages as organized in the texdoctk.dat
  file

Finally, if you call the command when your cursor is on a word in TextMate
this script will attempt to find the best match for that word as a package and
open the documentation for that package immediately.

Because good dvi viewers are quite rare on OS X, we also provide a simple
``viewDoc.sh script``. ``viewDoc.sh`` converts a dvi file (using ``dvipdfm``)
and opens it in Preview.

"""


# -- Imports ------------------------------------------------------------------

from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

from os import sys, path
sys.path.insert(1, path.dirname(path.dirname(path.abspath(__file__))) +
                "/lib/Python")

from io import open
from os import chdir, getenv, mkdir
from os.path import basename, exists, expanduser, getmtime, splitext
from pickle import load, dump
from pipes import quote as shellquote
from subprocess import check_output
try:
    from urllib.parse import quote  # Python 3
except ImportError:
    from urllib import quote  # Python 2

from tex import (find_tex_packages, find_tex_directives, find_file_to_typeset)


# -- Functions ----------------------------------------------------------------

def get_documentation_files(texmf_directory):
    """Get a dictionary containing tex documentation files.

    This function searches all directories under the ``texmf`` root for dvi or
    pdf files that might be documentation. It returns a dictionary containing
    file-paths. The dictionary uses the filenames without their extensions as
    keys.

    Arguments:

        texmf_directory

            The location of the main tex and metafont directory.

    Returns: ``{str: str}``

    Examples:

        >>> texmf_directory = check_output(
        ...     "kpsewhich --expand-path '$TEXMFMAIN'", shell=True,
        ...     universal_newlines=True).strip()
        >>> documentation_files = get_documentation_files(texmf_directory)
        >>> print(documentation_files['scrguide']) # doctest:+ELLIPSIS
        /.../scrguide.pdf

    """
    doc_files = check_output("find -E {} -regex '.*\.(pdf|dvi)' -type f".
                             format(shellquote(texmf_directory)),
                             shell=True, universal_newlines=True).splitlines()
    return {basename(splitext(line)[0]): line.strip() for line in doc_files}


def parse_texdoctk_data(documentation_files, texmf_directory):
    """Parse documentation data from ``texdoctk``.

    This function returns three dictionaries:

        paths

            Contains the path to documentation files describing certain topics.

        descriptions

            Contains text describing certain help topics.

        headings

            A dictionary containing headings. Each heading contains a list of
            help topics.

    Arguments:

        documentation_files

            A dictionary containing the paths of documentation files. The
            dictionary uses the filename/subject of the documentation file as
            key.

        texmf_directory

            The location of the main tex and metafont directory.

    Returns: ``[dict]``

    Examples:

        >>> texmf_directory = check_output(
        ...     "kpsewhich --expand-path '$TEXMFMAIN'", shell=True,
        ...     universal_newlines=True).strip()
        >>> paths, descriptions, headings = parse_texdoctk_data(
        ...     get_documentation_files(texmf_directory), texmf_directory)
        >>> print(paths['beamer']) # doctest: +ELLIPSIS
        /usr/local/texlive/.../texmf-dist/doc/latex/.../beameruserguide.pdf
        >>> print(descriptions['beamer'])
        User's Guide to the beamer class
        >>> 'beamer' in headings['Slides']
        True

    """
    texdoc_path = check_output(
        "kpsewhich --progname=texdoctk --format='other text files' " +
        "texdoctk.dat", shell=True, universal_newlines=True).strip()

    paths = {}
    descriptions = {}
    headings = {}

    with open(texdoc_path, 'r', encoding='utf-8') as docindex:
        for line in docindex:
            if line[0] == "#":
                continue
            elif line[0] == "@":
                heading = line[1:].strip()
                headings[heading] = []
            else:
                key, description, path, _ = [item.strip()
                                             for item in line.split(';')]
                headings[heading].append(key)

                if path.endswith('.sty'):
                    path = "{}/tex/{}".format(texmf_directory, path)
                else:
                    path = "{}/doc/{}".format(texmf_directory, path)
                    if not exists(path):
                        # Sometimes texdoctk.dat includes an incorrect path
                        # We try to get the path for the topic from the given
                        # documentation files
                        altkey = splitext(basename(path))[0]
                        if key in documentation_files:
                            path = documentation_files[key]
                        elif altkey in documentation_files:
                            path = documentation_files[altkey]

                paths[key] = path
                descriptions[key] = description

    return paths, descriptions, headings


def create_viewdoc_link(file_path, description,
                        tm_bundle_support=getenv('TM_BUNDLE_SUPPORT')):
    """Create a link that opens a given documentation file.

    Arguments:

        file_path

            The path to the file for which we want to create a link.

        description

            The description text of the link.

        tm_bundle_support

            The location of the support folder for this bundle.

    Returns: ``str``

    Examples:

        >>> print(create_viewdoc_link('file.pdf', 'description'))
        ...     # doctest:+ELLIPSIS
        <a href="javascript:...viewDoc.sh...file.pdf\', null);">description</a>

    """
    return ("""<a href="javascript: TextMate.system(""" +
            r"""'\'{}/bin/viewDoc.sh\' {}', null);">{}</a>""".format(
                tm_bundle_support, file_path, description))


# -- Main ---------------------------------------------------------------------

if __name__ == '__main__':

    # If the caret is right next to or between a word, then we show the
    # documentation for that word using the the shell command `texdoc`
    tm_current_word = getenv('TM_CURRENT_WORD')
    if tm_current_word:
        output = check_output("texdoc {}".format(shellquote(tm_current_word)),
                              shell=True).strip()
        # Close the html output window on success
        if not output:
            exit(200)

    # Find all the packages included in the file or its inputs
    master_file, master_dir = find_file_to_typeset(
        find_tex_directives(getenv("TM_FILEPATH")))
    chdir(master_dir)
    packages = find_tex_packages(master_file)

    texmf_directory = check_output("kpsewhich --expand-path '$TEXMFMAIN'",
                                   shell=True, universal_newlines=True).strip()
    docdbpath = "{}/Library/Caches/TextMate".format(expanduser('~'))
    docdbfile = "{}/latexdocindex".format(docdbpath)

    if exists(docdbfile) and getmtime(docdbfile) > getmtime(texmf_directory):
        # Read from cache
        with open(docdbfile, 'rb') as cache:
            paths, descriptions, headings = load(cache)
    else:
        # Parse the texdoctk database
        docfiles = get_documentation_files(texmf_directory)
        paths, descriptions, headings = parse_texdoctk_data(docfiles,
                                                            texmf_directory)

        # Supplement with searched for files
        for package in docfiles:
            if package not in paths:
                paths[package] = docfiles[package]
                descriptions[package] = package

        # Write cache file
        try:
            if not exists(docdbpath):
                mkdir(docdbpath)
            with open(docdbfile, 'wb') as cache:
                dump([paths, descriptions, headings], cache)
        except IOError:
            print("<p>Error: Could not cache documentation index</p>")

    # Print out the results in HTML/JavaScript
    # The JavaScript gives us the nifty expand collapse outline look
    tm_bundle_support = getenv('TM_BUNDLE_SUPPORT')
    css_location = quote('{}/css/texdoc.css'.format(tm_bundle_support))
    js_location = quote('{}/lib/JavaScript/texdoc.js'.format(
                        tm_bundle_support))
    print("""<link rel="stylesheet" href="file://{}">
             <script type="text/javascript" src="file://{}"
                 charset="utf-8"></script>
             <h1>Included Packages</h1>
             <ul>""".format(css_location, js_location))
    for package in packages:
        print("""<div id="mypkg"><li>{}</li></div>""".format(
              create_viewdoc_link(paths[package], descriptions[package],
                                  tm_bundle_support) if package in paths
              else package))
    print("""</ul><hr /><h1>Packages Browser</h1><ul>""")
    for heading in headings:
        print("""<li><a href="javascript:dsp(this)" class="dsphead"
                        onclick="dsp(this)">{}</a></li>
                 <div class="dspcont"><ul>
              """.format(heading))
        for package in headings[heading]:
            print("""<li>{}</li>""".format(
                  create_viewdoc_link(paths[package], descriptions[package],
                                      tm_bundle_support)
                  if exists(paths[package])
                  else package))
        print("""</ul></div>""")
    print("</ul>")
