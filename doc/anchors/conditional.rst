.. _conditionalAnchor:

.. index:: Conditional Anchors

Conditional Anchors
===================

It might happen that a feature is already present in the target environment.
In this case applying the integration again will most certainly break the target environment as
the feature will be there twice.
A common scenario might be an update or a patch, which is supposed to be compatible with different versions of the
target environment - a version where the feature already exists, and a version where it is yet to be added.

To accommodate for that, anchors can function as conditions.
These conditional anchors work on the same principles as ordinary :ref:`anchors <anchors>` with a few specialties.

With their :std:term:`regex.needles <regex.needle>` anchors usually pinpoint the position in a file where to modify it
and where to :ref:`insert <anchors.insert>` new content.
If there was no match an anchor will typically fail.
This is what is taken advantage of in conditional anchors.

.. _conditionalAnchorUsage:

Usage
-----

Assume there is a feature (call it XY) which should be integrated only if it does not exist.
For this, create an anchor which searches for a line that a file would only have, if XY was present.
This anchor will store 'found' (or anything else) in a :std:term:`global variable <storeVars>` named ``XYExists``.
Additionally, this anchor should set an :std:term:`ignoreOnFail` message like 'Feature XY not found'.
This anchor will have no :ref:`hook <anchors.hook>` or :ref:`insert <anchors.insert>` properties.
Now, the variable ``XYExists`` will only be written (and exist), if the anchor succeeds.
If the anchor fails, meaning it did not find the line in the file, the variable ``XYExists`` will not exist.
If there is a second anchor now that will have ``!XYExists`` as a :std:term:`global dependency <globalDependencies>`
(note the exclamation mark), it will only be called if the variable ``XYExists`` does not exist.
In this anchor, the integration of the feature can be implemented.
Additionally, this anchor should set an :std:term:`ignoreOnFail` message like 'Feature XY already exists'.

Here is an example of these two anchors with two log outputs below.

.. code-block:: JSON

    [
        {
            "description": "Find Feature XY",
            "path": "path\\to\\file_to_modify",
            "regex": {
                "needle": "some line that only exists if the feature is present"
            },
            "storeVars": {
                "XYExists": "found"
            },
            "dependencies": [
                "featureXY"
            ],
            "ignoreOnFail": "Feature XY not found. Will integrate it now."
        },

        {
            "description": "Integrate Feature XY",
            "path": "path\\to\\file_to_modify",
            "regex": {
                "needle": "some content after which to integrate the feature"
            },
            "hook": {
                "start": "$0",
                "length": "0",
                "before": false
            },
            "insert": {
                "string": "{lines}",
                "replace": {
                    "lines": "featureXY"
                }
            },
            "storeVars": {
                "XYExists": "integrated"
            },
            "globalDependencies": [
                "!XYExists"
            ],
            "dependencies": [
                "featureXY"
            ],
            "ignoreOnFail": "Feature XY already exists."
        }
    ]

If feature XY already exists, the log will look like this

.. code-block:: none

    1970-01-01 00:00:00 :: WARNING  :: Anchor #2(file_to_modify): RegEx not matched: [i] 'some content after which to integrate the feature' - Feature XY already exists.

If feature XY does not already exist, the log will look like this

.. code-block:: none

    1970-01-01 00:00:00 :: WARNING  :: Anchor #1(file_to_modify): RegEx not matched: [i] 'some line that only exists if the feature is present' - Feature XY not found. Will integrate it now.

Since a :std:term:`ignoreOnFail` message is set, the integration will not fail (stop due to an error) in either case,
but merely display the warnings seen above.
After both cases feature XY will be integrated, regardless of whether it was present or not.
This is how an update or patch setup can be created.

.. note::
    **Note**: This is not the only thing that is possible with conditional anchors.
    There is a lot of possibilities.
