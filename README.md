# ZILF-Choices

A small package for ZILF that adds twine-like multiple choice options.

---
## Table of Contents
1. [Installation](#installation)
2. [Use](#use)
3. [Restrictions](#restrictions)

# Installation

Download `choices.zil` and place it in your `zilf/zillib` folder.
You *should* then be able to use it like any other package using `<USE "CHOICES">` at the top of whatever ZILF project you have.

# Use

On any Room you create in ZILF that you want to have a forced set of numbered choices that the user must choose between, you will use the `CHOICES` property.
Each line will have the number of the choice (0-9), a string which will be shown to the player as that choice's text, and finally a room that the player will be moved to if they make that choice.
Here's a small example.

```
<ROOM STANELY-PARABLE (DESC "A Set of Two Doors")>
```
