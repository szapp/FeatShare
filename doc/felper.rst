.. _felper:

.. index:: Felper

Felper
======

The felper is a tool to help designing a suitable :ref:`regular expression <regex>`.
As the implementations of regular expressions vary across programming languages and environments, the felper comes in
handy to aid in figuring out the specifics.

Usage
-----

Start the felper and copy the base text into the upper panel.
The base text is the text in which an :ref:`anchor <anchors>` will try to match its regex.
In other words, this is the text in which you would like FeatShare to integrate new content.

The second panel is a compact version of an :ref:`anchor script <anchors>`.
Only the properties :std:term:`regex <regex>` and :std:term:`matchBracket <matchBracket>` are regarded.

.. note::
    **Note**: For more information on these terms, see :ref:`anchors <anchors>`.

The third panel shows all subpatterns and their names, e.g. ``$1``.
If a regex did not match or is malformated.
In the latter case the error will be displayed instead of the matches.
