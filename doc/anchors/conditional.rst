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
