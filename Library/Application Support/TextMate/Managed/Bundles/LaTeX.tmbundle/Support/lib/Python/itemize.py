#!/usr/bin/python
# coding=utf8

# -- Imports ------------------------------------------------------------------

from re import search


# -- Functions ----------------------------------------------------------------

def itemize(text, use_spaces_to_indent=True, number_of_spaces_for_indent=4,
            description_sign=":", characters_till_description_sign=20):
    r"""Create an itemize or description environment.

    This function creates an itemize or description environment from a given
    piece of text. Every line of text will become one item of the resulting
    environment. In the default case the function transforms the text into an
    itemize environment. If the first characters of every line of the text
    contain ``description_sign`` the text will be transformed into an
    description environment.

    Arguments:

        text

            A piece of text which we want to convert into an
            environment/description environment.

        use_spaces_to_indent

            Specifies if the items in the resulting environment should be
            indent using spaces instead of tabs.

        number_of_spaces_for_indent

            Specifies the number of spaces used to indent single items. This
            setting only applies if ``use_spaces_to_indent`` is set to
            ``True``.

        description_sign

            A character which indicates that we want to turn ``text`` into an
            description environment.

        characters_till_description_sign

            Specifies the number of character we search for description sign
            in every line of ``text``.

    Examples:

        >>> text = ("One is the loneliest number\n"
        ...         "An integer is called even if it is divisible by 2\n" +
        ...         "3 is the number of dimensions that humans can perceive\n")
        >>> print(itemize(text))
        \begin{itemize}
        <BLANKLINE>
            \item One is the loneliest number
        <BLANKLINE>
            \item An integer is called even if it is divisible by 2
        <BLANKLINE>
            \item 3 is the number of dimensions that humans can perceive
        <BLANKLINE>
        \end{itemize}
        <BLANKLINE>
        >>> text = ("  Jake: The dog\n\n" +
        ...         "  Finn: The human\n")
        >>> print(itemize(text, number_of_spaces_for_indent=2))
          \begin{description}
        <BLANKLINE>
            \item[Jake] The dog
        <BLANKLINE>
            \item[Finn] The human
        <BLANKLINE>
          \end{description}
        <BLANKLINE>
        >>> text = ("This item is too long: Bla\n" +
        ...         "Hello: World")
        >>> itemize(text, use_spaces_to_indent=False) # doctest:+ELLIPSIS
        '\\begin{i...}\n\n\t\\i...: Bla\n\n\t\\i...: World\n\n\\end{itemize}\n'
        >>> text = ("\n  You Fail Me" +
        ...         "\n  All We Love We Leave Behind")
        >>> print(itemize(text))
          \begin{itemize}
        <BLANKLINE>
              \item You Fail Me
        <BLANKLINE>
              \item All We Love We Leave Behind
        <BLANKLINE>
          \end{itemize}
        <BLANKLINE>
        >>> itemize("\t \n")
        '\t \n'

    """
    # Do not generate an environment if there is no text to itemize
    if text.isspace():
        return text

    # Remove empty lines and convert to list
    lines = text.splitlines()
    lines = [(search('(\s*)', line).group(0), line.strip())
             for line in lines if line]

    # Check if we should create a description environment
    descriptions = []
    description_environment = True
    for whitespace, line in lines:
        line_split = line.split(':')
        if (len(line_split) != 2 or
            (len(line_split) == 2 and
             len(line_split[0]) > characters_till_description_sign)):
            description_environment = False
            break
        descriptions.append((whitespace, line_split[0], line_split[1].strip()))

    # Create the environment
    indent = (' ' * number_of_spaces_for_indent if use_spaces_to_indent
              else '\t')
    if description_environment:
        lines = descriptions
        items = ['{}{}\item[{}] {}'.format(whitespace, indent, item,
                                           description) if item else whitespace
                 for whitespace, item, description in lines]
    else:
        items = ['{}{}\item {}'.format(whitespace, indent, item) if item
                 else whitespace for whitespace, item in lines]
    environment_indent = lines[0][0]

    return "{0}\\begin{{{1}}}\n\n{2}\n\n{0}\\end{{{1}}}\n{0}".format(
        environment_indent, 'description' if description_environment
        else 'itemize', '\n\n'.join(items))


# -- Main ---------------------------------------------------------------------

if __name__ == '__main__':
    # Import and run doc-tests
    import doctest
    doctest.testmod()
