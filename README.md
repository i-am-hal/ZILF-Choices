# ZILF-Choices

A small package for ZILF that adds twine-like multiple choice options.

---
## Table of Contents
1. [Inspiration](#inspiration)
2. [Installation](#installation)
3. [Use](#use)
4. [Restrictions and Notes](#restrictions-and-notes)
5. [Ideas and Future Improvements](#ideas-and-future-improvements)

## Inspiration

I've made a few small projects in Twine and had some real fun making games with the pre-set choices methodology. I recently wanted to have a sequence in a ZIL game involving preset choices as a way for the player to essentially make their own character (such as the beginning of the excellent *Suzerain*). However, I found there were no such implementations that were easy plug-and-play packages. So, here we are, I have attempted to do just that.

## Installation

Download `choices.zil` and place it in your `zilf/zillib` folder.
You *should* be able to use it like any other package using `<USE "CHOICES">` at the top of whatever ZILF project you have.

## Use

You will use the `CHOICES` property on any Room you create in ZILF that you want to have a forced set of numbered choices that the user must choose between.
Each line will have the number of the choice (0-9), a string that will be shown to the player as that choice's text, and finally, a room that the player will be moved to if they make that choice.
Here's a small example.

```ZIL
<ROOM STANELY-PARABLE (DESC "A Set of Two Doors")
  (FLAGS RLANDBIT LIGHTBIT)
  (LDESC "When Stanely came to a set of two open doors he..")
  (CHOICES
    1 "Entered the door on his left." TO LEFT-DOOR-PATH
    2 "Entered the door on his right." TO RIGHT-DOOR-PATH)>
```

Here `LEFT-DOOR-PATH` and `RIGHT-DOOR-PATH` are two separate room objects in your project.

#### Entry Functions, and Choice Exits
By utilizing the property `ENTRYFCN` you can specify a routine to be executed BEFORE the room is described. You could easily use this functionality to manipulate game state to register the choices of the player.

```ZIL
<ROOM WHAT-IS-YOUR-NAME? (DESC "A Question of Identity")
   (FLAGS RLANDBIT LIGHTBIT)
   (LDESC "Your parents decided to name you...")
   (CHOICES
      1 "Harold." TO NAMED-HAROLD
      2 "Miariam." TO NAMED-MIRIAM)>

<ROOM NAMED-HAROLD ...
   (ENTRYFCN SET-NAME-HAROLD) ...
   (CHOICEEXIT PASSIONS-OF-YOUTH)>

<ROOM NAMED-MIRIAM ...
   (ENTRYFCN SET-NAMED-MIRIAM) ...
   (CHOICEEXIT PASSIONS-OF-YOUTH)>
```
In this example we have the player choose their name, and we register that information, presumably in some variable in our game, with the rooms leading from each of those choices. Within the NAMED-HAROLD room is the property, `CHOICEEXIT` (which I really should rename.) This property will force the player to be moved to the room specified. In this case, both NAMED-HAROLD and NAMED-MIRIAM redirect to the room PASSIONS-OF-YOUTH, where, no-doubt another choice will be made by the player. Therefore these rooms, and their corresponding routines `SET-NAME-HAROLD` and `SET-NAME-MIRIAM` will modify game state to record our choices. I'm sure there could be a much more elegant way to capture this functionality, but for now, for my own purposes this suffices.

## Restrictions and Notes

Unfortunately, due to the way that I have currently implemented all of this, each room *(node?)* can have, at most, 10 choices (those corresponding to digits 0-9). You **cannot** use letters for differentiating your choices, either. Another thing to keep in mind is that while the LDESC of a room *will* be printed before the choices, all objects within a room won't be printed out. Any room that uses that choices property, too, will be kept from being able to enter parser inputs.

## Ideas and Future Improvements

I admit that this is really basic functionality, and probably *not* too useful for anything super amazing. I already have a few ideas on things I could *try* to add that I believe would give this the flexibility required for it to be, actually flexible enough that someone would want to *actually* use it for their project.

* Allow for letter inputs for choices, not just the digits 0-9
* Conditional choices (choices that only show up if some variable is true) *EG* `1 "Cast a spell to kill the wizard." IF KNOW-MAGIC`
* Specify a routine to execute before moving to a specified room.

I can't guarantee that I'll update this soon with these changes, or if I can even make these changes. I'll endeavor to do so, though. ZILF is a small and relatively new community, and I'd like there to be a wealth of packages for the language so authors can have an easier time writing their stories, instead of having to re-make some wheel.
