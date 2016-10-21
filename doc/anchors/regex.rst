.. _regex:

.. index:: Regular Expressions

Regular Expressions
===================

FeatShare relies heavily on regular expressions (here abbreviated with 'regex').
To integrate new content a line number does not suffice, as it might differ in the target environment.
A literal search phrase is also dangerous, since that phrase may have been altered with regards to spaces,
capitalization differing indices and much more.

If, for example, looking for a variable definition, the target environment might differ from what one would expect.

.. code-block:: C++

    var int variable;

.. code-block:: C++

    Var  INT  variable ; // Comment

Both definitions might be possible (syntax conform), yet differ too much for a normal search.
Searching for ``var int variable;`` would fail in the second case.

When instead using regular expressions, this problem can be avoided.
A case-insensitive regex search for ``^\s*var\s+int\s+variable\s*;.*$`` will succeed in both cases.

How regular expressions work and what different symbols mean is not covered in this documentation.

.. note::
    **Note:** Regex implementations vary. To help with finding an appropriate regex that matches in FeatShare use the
    :ref:`Felper <felper>`.

.. _subpatterns:

Subpatterns
-----------

One important part of regex in FeatShare is the matching of several subpatterns.

When enclosing parts of the regex needle (a needle is a search phrase as in haystack and needle) in parentheses ``( )``,
it may be referred to as subpattern later on.
Subpatterns are integers prefixed by ``$``, e.g. ``$1`` or ``$2``.

The match of the entire needle is always ``$0``.
If there are any subpatterns, they will have increasing integers starting from one.
I.e. the entire needle is represented in ``$0``, the first subpattern is ``$1``, the second is ``$2``, and so on.

In FeatShare subpatterns not only store the contents of the match but also the starting position and the length of the
match.
This allows the use subpatterns interchangeably for indices (e.g. :std:term:`hook.start` and :std:term:`hook.length`),
as well as for their content (e.g. :std:term:`hook.replace` and :std:term:`storeVars`).

.. note::
    **Note**: The :ref:`Felper <felper>` may help in determining the order of subpatterns in nested cases.

.. _regexflags:

Regex Flags
-----------

Regex utilizes flags to set extra options. A **limited** number of these options may be set in FeatShare.

For example: FeatShare has no need to match more than one occurrence. That is why the ``global`` flag is neither turned
on nor accessible in the regex flags.

.. note::
    **Note:** Regex implementations vary. To help with finding an appropriate regex that matches in FeatShare use the
    :ref:`Felper <felper>`.

.. glossary::

    flags.caseSensitive
        By default all regex's are case-insensitive. If a regex should, nevertheless, match exact phrases this setting
        can be set to ``true``.

    flags.dotInclNL
        If this setting is ``true``, the regex dot (``.``) matches all characters **including new lines**.

        **Note:** The setting should be avoided as much as possible.

    flags.multiLine
        Matches the regex anchors (``^`` and ``$``) against each line instead of the entire search string.

    flags.ungreedy
        Performs ungreedy matching, where only as few characters are matched as necessary.

    flags.occurrence
        Only in some cases this flag is available.
        It allows to specify which match should be targeted.
        Specify 2 for the second occurrence, -1 for the last occurrence, -2 for the second to last, and so on.
