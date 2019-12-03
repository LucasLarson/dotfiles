#!/usr/bin/python
# encoding: utf-8

# -- Imports ------------------------------------------------------------------

from __future__ import print_function
from __future__ import unicode_literals

from os import sys, path
sys.path.insert(1, path.dirname(path.dirname(path.abspath(__file__))) +
                "/lib/Python")

from argparse import ArgumentParser
from io import open
from os import getenv
from os.path import basename, dirname, join
from pickle import load, dump
from pipes import quote as shellquote
from subprocess import check_output, STDOUT
from sys import version_info

from parsing import LaTexMkParser
from tex import encodings
from gutter import update_marks

# -- Module Import ------------------------------------------------------------

PYTHON2 = version_info <= (3, 0)

if PYTHON2:
    import sys
    reload(sys)  # noqa
    sys.setdefaultencoding("utf-8")


# -- Functions ----------------------------------------------------------------

def notify(title='LaTeX Watch', summary='', messages=[], token=None):
    """Display a list of messages via a notification window.

    This function returns a notification token that can be used to reuse the
    opened notification window.

    Arguments:

        title

            The (window) title for the notification window.

        summary

            A summary explaining the reasoning why we show this notification
            window.

        messages

            A list of strings containing informative messages.

        token

            A token that can be used to reuse an already existing notification
            window.

    Returns: ``int``

    Examples:

        >>> token = notify(summary='Mahatma Gandhi', messages=[
        ...     "An eye for an eye only ends up making the whole world " +
        ...     "blind."])
        >>> # The token the function returns is a number
        >>> token = int(token)

    """
    dialog = getenv('DIALOG')
    tm_support = getenv('TM_SUPPORT_PATH')
    nib_location = '{}/nibs/SimpleNotificationWindow.nib'.format(tm_support)
    log = '\n'.join(messages).replace('\\', '\\\\').replace('"', '\\"')

    command = "{} nib".format(shellquote(dialog))
    content = shellquote(
        """{{ title = "{}"; summary = "{}"; log = "{}"; }}""".format(
            title, summary, log))

    # Update notification window
    if token:
        command_update = "{} --update {} --model {}".format(
                         command, token, content)
        notification_output = check_output(command_update, stderr=STDOUT,
                                           shell=True, universal_newlines=True)
        # If the window still exists and we could therefore update it here we
        # return the token of the old window. If we could not update the
        # window we get an error message. In this case we try to open a new
        # notification window.
        if notification_output.strip() == '':
            return(int(token))

    # Create new notification window
    command_load = "{} --load {} --model {}".format(
                   command, shellquote(nib_location), content)
    notification_output = check_output(command_load, shell=True,
                                       universal_newlines=True)
    return int(notification_output)


# -- Main ---------------------------------------------------------------------

if __name__ == '__main__':

    parser = ArgumentParser(
        description='Parse output from latexmk.')
    parser.add_argument(
        '-notify', default='', nargs='?',
        help="""Open a notification window to show warning and error messages.
                To reuse a notification window already opened, just provide
                its notification token.

                To open a new window containing old messages stored in the
                cache provide the argument `reload`. If the cache file does
                not exist yet or the old messages could not be read for some
                other reasons, then `reload` will just fail silently.""")

    parser.add_argument(
        'logfile',
        help="""The location of the log file that should be parsed.""")
    parser.add_argument(
        'file',
        help="""The location of the (master) tex file without its extension.
                This has to be the file from which the output in `logfile` was
                generated.""")
    arguments = parser.parse_args()

    logfile = arguments.logfile
    notification_token = arguments.notify
    texfile = '{}.tex'.format(arguments.file)
    cachefile = join(dirname(arguments.file),
                     '.{}.lb'.format(basename(arguments.file)))

    if notification_token == 'reload':
        try:
            # Try to read from cache
            with open(cachefile, 'rb') as storage:
                typesetting_data = load(storage)
                messages = typesetting_data['messages']
            notification_token = None
        except IOError:
            # Fail silently
            exit(0)
    else:
        # Depending on the error the tex engine might return a log file in a
        # different encoding.
        for encoding in encodings:
            try:
                texparser = LaTexMkParser(open(logfile, encoding=encoding),
                                          verbose=False, filename=texfile)
                texparser.parse_stream()
                break
            except UnicodeDecodeError:
                continue
        # Sort marks by line number
        marks = sorted(texparser.marks, key=lambda marks: marks[1])
        update_marks(cachefile, marks)
        messages = ["{:<7} {}:{} — {}".format(severity.upper(),
                    basename(filename), line, message)
                    for (filename, line, severity, message) in marks]
        if not messages:
            messages = [
                "Could not find any messages containing line information.",
                "Please take a look at the log file {}.latexmk.log ".format(
                    basename(arguments.file)) +
                "to find the source of the problem."]

        try:
            # Try to update data in cache file
            with open(cachefile, 'r+b') as storage:
                typesetting_data = load(storage)
                typesetting_data['messages'] = messages
                storage.seek(0)
                dump(typesetting_data, storage)
        except IOError:
            print('Could not access cache file {}!'.format(cachefile))

    if notification_token != '':
        new_token = notify(
            summary='Errors While Typesetting {}'.format(basename(texfile)),
            messages=messages, token=notification_token)
        print("Notification Token: |{}|".format(new_token))
