.. _tutorial:

.. index:: Tutorial (Quick Start)

Tutorial (Quick Start)
======================

At the start of each setup are of course the features which should be integrated into an existing file structure.

Nevertheless, there is a little more to setup. This is a short outline of what we need to do.

#. :ref:`Create a configuration file <tutorialConfigJson>`
#. :ref:`Select what to integrate <tutorialFeatures>`
#. :ref:`Create anchors <tutorialAnchors>`

Premise
-------

Imagine a programming project in which we want to modify a method.

This project is shared with different parties.
The project turned into many independent projects, all sharing the same base structure, but differing a lot.
Of course, the projects are not compatible anymore and exchanging files is not possible.
As an unlikely small-scale example, let's consider a java project with one file of interest.
Here are parts we want to modify.

path\\to\\file1\\method1.java::

    121  ...
    122
    123  public static int subtract2(int i)
    124  {
    125     return i-2;
    126  }
    127
    128  ...

The only really certain information we have about were to find the parts are the file it is in and the method signature.

The first though might be to just search and replace the affected parts or replace the lines by line number.
However, take a look how the ``method1.java`` looks on a different computer::

    243  ...
    244
    245      private static int  subtract2 ( int i ) { // Subtract 2 from integer
    246          return i-2;
    247      }
    248
    249  ...

First of all, the line numbers are different. The other person seems to have added a lot to the file. Also, and more
importantly, the spelling and white spaces are different, the code is indented and the open curly bracket is in the same
line instead of the next. How do we go about this?

Clearly we need to make as little assumptions on the parts we are searching as possible. For that we use
:ref:`regular expressions <regex>`.


.. _tutorialConfigJson:

1. Configuration: config.json
-----------------------------

Before doing anything else, we will first write some general settings for the setup.

All of those settings are set using a file named :ref:`config.json <configjson>`.
Without this file the setup cannot be build.
Therefore, the first thing we need to do now is create a file named ``config.json``.
Let's keep it simple for now and write the following lines to it.
Mind the commas and the brackets.
Indentation is not important but helps for readability.

.. container:: coderef

    | {
    |     :std:term:`"title" <title>`: "My First FeatShare Setup",
    |     :std:term:`"globalHeader" <globalHeader>`: "// The lines of code below were inserted by my FeatShare setup!",
    |     :std:term:`"installInstruction" <installInstruction>`: "Choose the directory in which to integrate the features",
    |     :std:term:`"defaultPath" <defaultPath>`: "C:\\\\Data\\\\MyProject\\\\",
    |     :std:term:`"dryRun" <dryRun>`: true,
    |     :ref:`"anchors" <config.anchors>`: {
    |         "": "^anchors.*\\\\.json$"
    |     }

There is a lot more that can be set here.
The absolute minimum for a config file is the setting :ref:`"anchors" <config.anchors>`.
For detailed descriptions and explanations see :ref:`config.json <configjson>` or click on the references above.

.. _tutorialFeatures:

2. Features
-----------

Next we need to decide **what** we want to integrate - the **how** comes later.

The *what* will be stored in a feature file.
Each feature has its own file. What exactly defines a feature is up to you.
The name of the feature files are up to you as well as the :std:term:`file extension <features.filePattern>`.
Here we will stick to the default file extension, since we didn't specify otherwise in the
:ref:`configuration <tutorialConfigJson>` and name the feature file ``newFeature.feat``.

Let's assume we want to change the ``subtract2()`` method to a ``subtract3()`` method.

The first thing we define in this file is the information text.
This text is the description that will be displayed when selecting the feature in the setup before starting the
integration::

    ### infoText ###
    This feature changes the subtract2 method into a subtract3.
    ### end ###

The next thing we do is specify what is going to be added.
In this example we change the subtrahend.
So let's add the new one like this::

    ### infoText ###
    This feature changes the subtract2 method into a subtract3.
    ### subtrahend ###
    3
    ### end ###

.. _tutorialAnchors:

3. Anchors
----------

Once we know what to insert, we need to make sure it's integrated at the right position - now comes the **how**.

The method name as well as the return value need to be changed.
(The fact the all references to the method need to be updated we will neglect for the sake of this simple example.)
That makes up two separate changes we need to perform.
So we will need two anchors for this.

As seen above ``method1.java`` may vary a lot in appearance.
Since we want to grab a hold of ``subtract2()``, we need to create a :ref:`regular expression <regex>` that will match that line.

.. note::
    **Note**: In general it is always helpful to make use of the :ref:`Felper <felper>` to find a suited regular expression.

Here, this regex will match the method signature::

    ^\s*(public|private)\s+static\s+int\s+subtract(2)\s*\(\s*int\s*.+\).*$

With the parentheses around ``2`` this regex will create the subpattern ``$1`` for 2.
We will use this to explicitly replace the 2.

.. note::
    **Note**: Back-slashes of the regex need to be escaped by an additional backslash (e.g. ``\\``).

.. container:: coderef

    | {
    |     :std:term:`"description" <description>`: "Update method signature",
    |     :std:term:`"path" <path>`: "path\\to\\file1\\method1.java",
    |     :std:term:`"regex" <regex>`: {
    |         :std:term:`"needle" <regex.needle>`: "^\\\\s*(public|private)\\\\s+static\\\\s+int\\\\s+subtract(2)\\\\s*\\\\(\\\\s*int\\\\s*.+\\\\).*$",
    |         :std:term:`"flags" <regex.flags>`: {
    |             :std:term:`caseSensitive" <regex.flags.caseSensitive>`: false,
    |             :std:term:`"dotInclNL" <regex.flags.dotInclNL>`: false,
    |             :std:term:`"multiLine" <regex.flags.multiLine>`: true,
    |             :std:term:`"ungreedy" <regex.flags.ungreedy>`: false,
    |             :std:term:`"occurrence" <regex.flags.occurrence>`: 1
    |         }
    |     },
    |     :ref:`"hook" <anchors.hook>`: {
    |         :std:term:`"start" <hook.start>`: "$0",
    |         :std:term:`"length" <hook.length>`: "$0",
    |         :std:term:`"before" <hook.before>`: false,
    |         :std:term:`"replace" <hook.replace>`: {
    |             "$1": "subtrahend"
    |         }
    |     },
    |     :ref:`"insert" <anchors.insert>`: {
    |         :std:term:`"string" <insert.string>`: "{newContent}",
    |         :std:term:`"replace" <insert.replace>`: {
    |             "newContent": "subtrahend"
    |         },
    |         :std:term:`"indent" <insert.indent>`: {
    |             :std:term:`"string" <insert.indent.string>`: "{ :4}",
    |             :std:term:`"exclFirstLine" <insert.indent.exclFirstLine>`: false,
    |             :std:term:`"exclHeader" <insert.indent.exclHeader>`: false
    |         }
    |     },
    |     :std:term:`"setHeader" <setHeader>`: true,
    |     :std:term:`"dependencies" <dependencies>`: [
    |         "subtrahend"
    |     ],
    |     :std:term:`"ignoreOnFail" <ignoreOnFail>`: false
    | }
