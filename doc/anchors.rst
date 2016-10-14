.. _anchors:

.. index:: Anchors

Anchors
=======

.. toctree::
    :hidden:

    anchors/index
    anchors/regex
    anchors/hooks
    anchors/conditional

This is one anchor with a complete list of settings.

.. container:: coderef



    | {
    |     :std:term:`"description" <description>`: "Anchor description",
    |     :std:term:`"path" <path>`: "path\\to\\file_to_modify",
    |     :std:term:`"regex" <regex>`: {
    |         "needle": "const.+int.+CUT_OFF.*=[^\\d]*(\\d+).*$",
    |         "flags": {
    |             "caseSensitive": false,
    |             "dotInclNL": false,
    |             "multiLine": true,
    |             "ungreedy": false,
    |             "occurrence": 1
    |         }
    |     },
    |     :std:term:`"matchBracket" <matchBracket>`: {},
    |     :std:term:`"storeVars" <storeVars>`: {
    |         "max_const": "$1"
    |     },
    |     :std:term:`"hook" <hook>`: {
    |         :std:term:`"start" <hook.start>`: "$0",
    |         :std:term:`"length" <hook.length>`: "$0",
    |         :std:term:`"before" <hook.before>`: true,
    |         :std:term:`"replace" <hook.replace>`: {
    |             "$1": "{idx}"
    |         }
    |     },
    |     :std:term:`"insert" <insert>`: {
    |         :std:term:`"string" <insert.string>`: "const int {const_name}{ :const_name:19}= {idx};\n",
    |         :std:term:`"replace" <insert.replace>`: {
    |             "const_name": "const"
    |         },
    |         :std:term:`"stripTrailingNL" <stripTrailingNL>`: false,
    |         :std:term:`"indent" <indent>`: {
    |             :std:term:`"string" <indent.string>`: "",
    |             :std:term:`"exclFirstLine" <indent.exclFirstLine>`: false,
    |             :std:term:`"exclHeader" <indent.exclHeader>`: false
    |         }
    |     },
    |     :std:term:`"newlinesBefore" <newlinesBefore>`: 0,
    |     :std:term:`"newlinesAfter" <newlinesAfter>`: 1,
    |     :std:term:`"localHeader" <localHeader>`: "",
    |     :std:term:`"setHeader" <setHeader>`: true,
    |     :std:term:`"finalReplace" <finalReplace>`: [
    |         {
    |             :std:term:`"needle" <finalReplace.needle>`: "idx",
    |             :std:term:`"replace" <finalReplace.replace>`: "max_const",
    |             :std:term:`"incr" <finalReplace.incr>`: 1,
    |             :std:term:`"first" <finalReplace.first>`: "0",
    |             :std:term:`"last" <finalReplace.last>`: "1000",
    |         }
    |     ],
    |     :std:term:`"deleteFiles" <deleteFiles>`: {
    |         :std:term:`"paths" <deleteFiles.paths>`: [],
    |         :std:term:`"replace" <deleteFiles.replace>`: {}
    |     },
    |     :std:term:`"globalDependencies" <globalDependencies>`: [],
    |     :std:term:`"dependencies" <dependencies>`: [
    |         "const"
    |     ],
    |     :std:term:`"ignoreOnFail" <ignoreOnFail>`: false
    | }

General Settings
----------------

.. glossary::

    description
        tbd

    path
        tbd

    regex
        tbd

    needle
        tbd

    flags
        tbd

    matchBracket
        tbd

    storeVars
        tbd

    hook
        tbd

    hook.start
        tbd

    hook.length
        tbd

    hook.before
        tbd

    hook.replace
        tbd

    insert
        tbd

    insert.string
        tbd

    insert.replace
        tbd

    stripTrailingNL
        tbd

    indent
        tbd

    indent.string
        tbd

    indent.exclFirstLine
        tbd

    indent.exclHeader
        tbd

    newlinesBefore
        tbd

    newlinesAfter
        tbd

    localHeader
        tbd

    setHeader
        tbd

    finalReplace
        tbd

    finalReplace.needle
        tbd

    finalReplace.replace
        tbd

    finalReplace.incr
        tbd

    finalReplace.first
        tbd

    finalReplace.last
        tbd

    deleteFiles
        tbd

    deleteFiles.paths
        tbd

    deleteFiles.replace
        tbd

    globalDependencies
        tbd

    dependencies
        tbd

    ignoreOnFail
        tbd
