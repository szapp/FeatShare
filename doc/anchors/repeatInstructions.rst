.. _repeatInstructions:

.. index:: Repeat-Instructions

Repeat-Instructions
===================

When replacing text, there is an instruction to repeat single characters several times.
This may be used for padding.
There is two different types of repeat-instructions.

.. _constrainedRepeatInstructions:

.. index:: Constrained Repeat-Instructions

Constrained Repeat-Instructions
-------------------------------

Constrained repeat-instructions allow the simple repetition of single characters.
The syntax is ``{C:x}``, where ``C`` is a single character and ``x`` is the number of repetitions.
For example, instead of entering 20 spaces this can be abbreviated with ``{ :20}``.

Also new line and tab characters can be padded (even though they are longer than one character in text form), e.g.
``{\t:4}`` will insert four tabs.

Constrained repeat-instructions are allowed in

    - :std:term:`hook.replace`
    - :std:term:`deleteFiles.replace`
    - :std:term:`insert.replace`
    - :ref:`finalReplace <anchors.finalReplace>`

.. index:: Padded Repeat-Instructions

Padded Repeat-Instructions
--------------------------

When an anchor is replacing a phrase, the replacement text might not be known at the time of definition.
This is the case, for example, if the replacement text is a :std:term:`variable <storeVars>` or a
:ref:`regex subpattern <subpatterns>`.
There it would be nice to make the repetitions dependend on the length of the inserted text.
Padded repeat-instructions (or unconstrained repeat-instructions) take one additional argument to
:ref:`constrained repeat-instructions <constrainedRepeatInstructions>`.
The syntax ``{C:var:x}`` where ``C`` is a single character and ``x - length(var)`` is the number of repetitions.
This enables dynamic padding and filling.

For example, ``{ :var:12}``, where ``var`` takes the values *"short"* and *"very long"*, will wesult in:

.. code-block:: none

    const int short        = 1;
    cosnt int very long    = 2;

instead of this, when only using ``{var}``:

.. code-block:: none

    const int short = 1;
    cosnt int very long = 2;

(Unconstrained) repeat-instructions are allowed in
    - :std:term:`insert.replace`
    - :ref:`finalReplace <anchors.finalReplace>`
