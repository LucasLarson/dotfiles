# -*- coding: utf-8 -*-

# -----------------------------------------------------------------------------
# Author: Brad Miller
# -----------------------------------------------------------------------------

"""This module contains various functions for handling tex data."""

# -- Imports ------------------------------------------------------------------

from __future__ import print_function
from __future__ import unicode_literals

from io import open
from os import chdir, getenv, EX_OSFILE  # noqa
from os.path import basename, dirname, isfile, join, normpath, realpath
from pipes import quote as shellquote
from re import compile
from subprocess import Popen, PIPE
from sys import exit, stdout


# -- Global Variables ---------------------------------------------------------

# The list of encodings we try to open files with.
encodings = ['utf_8', 'mac_roman', 'latin_1', 'gb2312', 'cp1251', 'cp1252']


# -- Exit Codes ---------------------------------------------------------------

EXIT_LOOP_IN_TEX_ROOT = -1
EXIT_FILE_ERROR = EX_OSFILE


# -- Functions ----------------------------------------------------------------

def expand_name(filename, program='pdflatex'):
    """Get the expanded file name for a certain tex file.

    Arguments:

        filename

                The name of the file we want to expand.

        program

                The name of the tex program for which we want to expand the
                name of the file.

    Returns: ``str``

    Examples:

        >>> print(expand_name('Tests/TeX/text.tex'))
        Tests/TeX/text.tex
        >>> print(expand_name('non_existent_file.tex'))
        non_existent_file.tex

    """
    if isfile(filename):
        return filename
    stdout.flush()
    run_object = Popen("kpsewhich -progname='{}' {}".format(
        program, shellquote(filename)), shell=True, stdout=PIPE,
        universal_newlines=True)
    expanded_filepath = run_object.stdout.read().strip()
    return expanded_filepath if expanded_filepath else filename


def determine_typesetting_directory(ts_directives,
                                    master_document=getenv('TM_LATEX_MASTER'),
                                    tex_file=getenv('TM_FILEPATH', '')):
    """Determine the proper directory for typesetting the current document.

    The typesetting directory is set according to the first applicable setting
    in the following list:

        1. The typesetting directive specified via the line

                ``%!TEX root = path_to_tex_file``

            somewhere in your tex file

        2. the value of ``TM_LATEX_MASTER``, or
        3. the location of the current tex file.

    Arguments:

        ts_directives

            A dictionary containing typesetting directives. If it contains the
            key ``root`` then the path in the value of ``root`` will be used
            as typesetting directory.

        master_document

            Specifies the location of the master document
            (``TM_LATEX_MASTER``).

        tex_file

            The location of the current tex file

    Returns: ``str``

    Examples:

        >>> ts_directives = {'root' : 'Tests/makeindex.tex'}
        >>> print(determine_typesetting_directory(ts_directives))
        ...     # doctest:+ELLIPSIS
        /.../Tests
        >>> print(determine_typesetting_directory( # doctest:+ELLIPSIS
        ...     {}, master_document='Tests/external_bibliography'))
        /.../Tests

    """
    tex_file_dir = dirname(tex_file)

    if 'root' in ts_directives:
        master_path = dirname(ts_directives['root'])
    elif master_document:
        master_path = dirname(master_document)
    else:
        master_path = tex_file_dir

    if master_path == '' or not master_path.startswith('/'):
        master_path = normpath(realpath(join(tex_file_dir, master_path)))

    return master_path


def find_tex_packages(filepath, ignore_nonexistent_files=False):
    """Find packages included by the given file.

    This function searches for packages in:

        1. The preamble of ``filepath``, and
        2. files included in the preamble of ``filepath``.

    Arguments:

        filepath

            The path to the file which should be searched for packages.

        ignore_nonexistent_files

            This option specifies if this function exits with an error code if
            it encounters a file it can not open.

    Returns: ``{str}``

    Examples:

        >>> chdir('Tests/TeX')
        >>> packages = find_tex_packages('packages.tex')
        >>> isinstance(packages, set)
        True
        >>> for package in sorted(packages):
        ...     print(package)
        booktabs
        csquotes
        framed
        mathtools
        polyglossia
        xcolor
        >>> 'inputenc' in list(find_tex_packages('applemac.tex'))
        True
        >>> chdir('../..')

    """
    filepath = expand_name(filepath)
    if not isfile(filepath):
        if ignore_nonexistent_files:
            return set()
        print("""<p class="error">Cannot open {} to check for packages.</p>
                 <p class="error">This is most likely a problem with
                                  TM_LATEX_MASTER</p>
              """.format(filepath))
        exit(EXIT_FILE_ERROR)

    option_regex = r'\[[^\]]+\]'
    argument_regex = r'\{([^}#]+)\}'
    input_regex = compile(r'[^%]*?\\input{}'.format(argument_regex))
    package_regex = compile(r'[^%]*?\\usepackage(?:{})?{}'.format(
                            option_regex, argument_regex))
    begin_regex = compile(r'[^%]*?\\begin\{document\}')

    # Search for packages and included files in the tex document
    done_reading = False
    included_files = set()
    packages = set()
    for encoding in encodings:
        try:
            with open(filepath, encoding=encoding) as file:
                for line in file:
                    match_input = input_regex.match(line)
                    match_package = package_regex.match(line)
                    if match_input:
                        included_files.add(match_input.group(1))
                    if match_package:
                        packages.add(match_package.group(1))
                    if begin_regex.match(line):
                        break
                done_reading = True
        except UnicodeDecodeError:
            # The current encoding is not correct. Try the next one.
            continue
        if done_reading:
            break

    # Search for packages in all files till we find the beginning of the
    # document and therefore the end of the preamble
    included_files = [included_file if included_file.endswith('.tex')
                      else '{}.tex'.format(included_file)
                      for included_file in included_files]
    match_begin = False
    while included_files and not match_begin:
        filepath = expand_name(included_files.pop())
        if not isfile(filepath):
            if not ignore_nonexistent_files:
                print('<p class="warning">Warning: Cannot open ' +
                      '{} to check for packages.</p>'.format(filepath))
            continue

        done_reading = False
        for encoding in encodings:
            try:
                with open(filepath, encoding=encoding) as file:
                    for line in file:
                        match_package = package_regex.match(line)
                        match_begin = begin_regex.match(line)
                        if match_package:
                            packages.add(match_package.group(1))
                        if match_begin:
                            break
                    done_reading = True
            except UnicodeDecodeError:
                # The current encoding is not correct. Try the next one.
                continue
            if done_reading:
                break

    # Split package definitions of the form 'package1, package2' into
    # 'package1', 'package2'
    package_set = set()
    for package in packages:
        package_set.update(package.strip()
                           for package in package.split(','))
    return package_set


def find_tex_directives(texfile, ignore_root_loops=False):
    """Build a dictionary of %!TEX directives.

    The main ones we are concerned with are:

       root

           Specifies a root file to run tex on for this subsidiary

       TS-program

            Tells us which latex program to run

       TS-options

           Options to pass to TS-program

       encoding

            The text encoding of the tex file

    Arguments:

        texfile

            The initial tex file which should be searched for tex directives.
            If this file contains a “root” directive, then the file specified
            in this directive will be searched next.

        ignore_root_loops

            Specifies if this function exits with an error status if the tex
            root directives contain a loop.

    Returns: ``{str: str}``

    Examples:

        >>> chdir('Tests/TeX')
        >>> directives = find_tex_directives('input/packages_input1.tex')
        >>> print(directives['root']) # doctest:+ELLIPSIS
        /.../Tests/TeX/packages.tex
        >>> print(directives['TS-program'])
        xelatex
        >>> find_tex_directives('makeindex.tex')
        {}
        >>> chdir('../..')

    """
    if not texfile:
        return {}
    root_chain = [texfile]
    directive_regex = compile(r'%\s*!T[E|e]X\s+([\w-]+)\s*=\s*(.+)')
    directives = {}
    while True:
        for encoding in encodings:
            try:
                lines = [line for (line_number, line)
                         in enumerate(open(texfile, encoding=encoding))
                         if line_number < 20]
                break
            except UnicodeDecodeError:
                continue

        new_directives = {directive.group(1): directive.group(2).rstrip()
                          for directive
                          in [directive_regex.match(line) for line in lines]
                          if directive}
        directives.update(new_directives)
        if 'root' in new_directives:
            root = directives['root']
            new_tex_file = (root if root.startswith('/') else
                            realpath(join(dirname(texfile), root)))
            directives['root'] = new_tex_file
        else:
            break

        if new_tex_file in root_chain:
            if ignore_root_loops:
                break
            print('''<div id="commandOutput"><div id="preText">
                     <p class="error">There is a loop in your %!TEX root
                                      directives.</p>
                     </div></div>''')
            exit(EXIT_LOOP_IN_TEX_ROOT)
        else:
            texfile = new_tex_file
            root_chain.append(texfile)

    return directives


def find_file_to_typeset(tyesetting_directives,
                         master_document=getenv('TM_LATEX_MASTER'),
                         tex_file=getenv('TM_FILEPATH', '')):
    """Determine which tex file to typeset.

    This is determined according to the following options:

       - %!TEX root directive
       - The ``TM_LATEX_MASTER`` environment variable
       - The environment variable ``TM_FILEPATH``

       This function returns a tuple containing the name and the path to the
       file which should be typeset.

    Arguments:

        ts_directives

            A dictionary containing typesetting directives. If it contains the
            key ``root`` then the value of ``root`` will be used for
            determining the file which should be typeset.

        master_document

            Specifies the location of the master document
            (``TM_LATEX_MASTER``).

        tex_file

            The location of the current tex file

    Returns: (``str``, ``str``)

    Examples:

        >>> file, directory = find_file_to_typeset({'root':
        ...                                         'Tests/makeindex.tex'})
        >>> print('({}, {})'.format(file, directory))  # doctest:+ELLIPSIS
        (makeindex.tex, .../Tests)

        >>> file, directory = find_file_to_typeset({},
        ...     master_document='../packages.tex',
        ...     tex_file='Tests/input/packages_input1.tex')
        >>> print('({}, {})'.format(file, directory))  # doctest:+ELLIPSIS
        (packages.tex, .../Tests)

        >>> file, directory = find_file_to_typeset(
        ...     {'root': '../packages.tex'}, None,
        ...     tex_file='Tests/input/packages_input1.tex')
        >>> print('({}, {})'.format(file, directory))  # doctest:+ELLIPSIS
        (packages.tex, .../Tests)

        >>> file, directory = find_file_to_typeset({}, None,
        ...                                        'Tests/packages.tex')
        >>> print('({}, {})'.format(file, directory))  # doctest:+ELLIPSIS
        (packages.tex, .../Tests)

    """
    if 'root' in tyesetting_directives:
        master = tyesetting_directives['root']
    elif master_document:
        master = master_document
    else:
        master = tex_file

    return (basename(master),
            determine_typesetting_directory(tyesetting_directives,
                                            master_document, tex_file))
