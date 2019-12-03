# -*- coding: utf-8 -*-

"""This module contains function to modify the gutter area of the editor."""

# -- Imports ------------------------------------------------------------------

from __future__ import print_function
from __future__ import unicode_literals

from io import open
from os import getenv
from os.path import normpath, realpath
from pickle import load, dump
from pipes import quote as shellquote
from subprocess import call


# -- Functions ----------------------------------------------------------------

def update_marks(cache_filename, marks_to_set=[]):
    """Set or remove gutter marks.

    This function starts by removing marks from the files specified inside the
    dictionary item ``files_with_guttermarks`` stored inside the ``pickle``
    file ``cache_filename``. After that it sets all marks specified in
    ``marks_to_set``.

    cache_filename

        The path to the cache file for the current tex project. This file
        stores a dictionary containing the item ``files_with_guttermarks``.
        ``files_with_guttermarks`` stores a list of files, from which we need
        to remove gutter marks.

    marks_to_set

        A list of tuples of the form ``(file_path, line_number, marker_type,
        message)``, where file_path and line_number specify the location where
        a marker of type ``marker_type`` together with an optional message
        should be placed.

    Examples:

        >>> marks_to_set = [('Tests/TeX/lualatex.tex', 1, 'note',
        ...                  'Lua was created in 1993.'),
        ...                 ('Tests/TeX/lualatex.tex', 4, 'warning',
        ...                  'Lua means "Moon" in Portuguese.'),
        ...                 ('Tests/TeX/lualatex.tex', 6, 'error', None)]
        >>> data = {'files_with_guttermarks': {'Tests/TeX/lualatex.tex'}}
        >>> cache_filename = '.test.lb'
        >>> with open(cache_filename, 'wb') as storage:
        ...     dump(data, storage)

        Set marks
        >>> update_marks(cache_filename, marks_to_set)

        Remove marks
        >>> update_marks(cache_filename)
        >>> from os import remove
        >>> remove(cache_filename)

        Working with a non existent file should just set the marks in
        ``marks_to_set``
        >>> update_marks('non_existent_file')
        >>> remove('non_existent_file')

    """
    try:
        # Try to read from cache
        with open(cache_filename, 'rb') as storage:
            typesetting_data = load(storage)
            files_with_guttermarks = typesetting_data['files_with_guttermarks']
            marks_to_remove = []
            for filename in files_with_guttermarks:
                marks_to_remove.extend([(filename, 'error'),
                                        (filename, 'warning')])
    except (IOError, ValueError):
        typesetting_data = {}
        marks_to_remove = []

    try:
        # Try to write cache data for next run
        newfiles = {filename for (filename, _, _, _) in marks_to_set}
        if 'files_with_guttermarks'in typesetting_data:
            typesetting_data['files_with_guttermarks'].update(newfiles)
        else:
            typesetting_data['files_with_guttermarks'] = newfiles
        with open(cache_filename, 'wb') as storage:
            dump(typesetting_data, storage)
    except Exception:
        print('<p class="warning"> Could not write cache file {}!</p>'.format(
              cache_filename))

    marks_remove = {}
    mate = getenv('TM_MATE')
    for filepath, mark in marks_to_remove:
        path = normpath(realpath(filepath))
        marks = marks_remove.get(path)
        if marks:
            marks.append(mark)
        else:
            marks_remove[path] = [mark]

    marks_add = {}
    for filepath, line, mark, message in marks_to_set:
        path = normpath(realpath(filepath))
        message = shellquote(message) if message else None
        marks = marks_add.get(path)
        if marks:
            marks.append((line, mark, message))
        else:
            marks_add[path] = [(line, mark, message)]

    commands = {filepath: '{} {}'.format(mate,
                                         ' '.join(['-c {}'.format(mark) for
                                                   mark in marks]))
                for filepath, marks in marks_remove.items()}

    for filepath, markers in marks_add.items():
        command = ' '.join(['-l {} -s {}{}'.format(line, mark,
                                                   ":{}".format(content) if
                                                   content else '')
                            for line, mark, content in markers])
        commands[filepath] = '{} {}'.format(commands.get(filepath, mate),
                                            command)

    for filepath, command in commands.items():
        call("{} {}".format(command, shellquote(filepath)), shell=True)
