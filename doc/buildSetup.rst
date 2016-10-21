.. _buildSetup:

.. index:: Build Setup

Build Setup
===========

FeatShare come with a primitive setup builder.

Requirements
------------

For building a setup at least a :ref:`config <configjson>` must exist.
Usually a setup consists of four file types:

    - :ref:`Configuration file <configjson>` (always called ``config.json``)
    - :ref:`Feature files <features>` (file name specified in configuration)
    - :ref:`Anchor file(s) <anchors>` (file name(s) specified in configuration)
    - :ref:`Files to copy <features.fileCopy>` (optional)

In small projects the anchors can be included in the configuration file with the
:ref:`anchors setting <config.anchors>`.
This does, however, offer no advantages and separating configuration from anchors is always a good idea.

Make sure you have the necessary files before starting.

Building a Setup
----------------

To build a setup start the file ``BuildSetup.exe`` included in the release.

First browse to the location where you want to create your setup ("Setup file to create").

**Before adding any other file**, browse to the config file which has to have the name ``config.json`` ("Path to
config file").
This will add the config.json to the list below and automatically add any referenced anchor files.

When you have confirmed that the list is correct (no anchor files missing), continue to add the feature files by drag
and drop into the list.

Lastly, add all files to be copied referenced by the anchors and features.
Do not worry if there are a lot of files included in your setup.
The builder will compress all files with LZMA-compression with mpress v2.19.

.. note::
    **Note**: The order the files appear in the list is not relevant.
    However, it is very important that the relative paths are shown and match the paths specified in the anchors and
    features.

The UI for building is rather limited.
If you add file in a wrong way or something similar, the only option is to clear the list and start over.
Therefore, it is a good idea to put all necessary files into one directory to add them with a single drag and drop
action.

Finally, hit the "Build Setup" button and wait for the file compression to finish.
The duration of building a setup depends on the size of the files added.
Afterwards, everything will be packed into a single executable.
