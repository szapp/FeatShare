.. _regex:

.. index:: Regular Expressions

Regular Expressions
===================


.. _regexflags:

Regex Flags
-----------

Regex utilizes flags to set extra options. A **limited** number of these options may be set in FeatShare.

For example: FeatShare has no need to match more than one occurrence. That is why the ``global`` flag is neither turned
on nor accessible in the regex flags.

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
