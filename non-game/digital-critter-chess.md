# Critter Chess

A bunch of animals. Each one moves in a _unique way_ (inspired by chess but simplified): one moves horizontal, one vertical, one diagonal, one hops, etcetera.

You simply need to get them all to target squares. => Click on one, it highlights your possible squares, click the desired one to move. => NO THIS IS LATER DIFFICULTY LEVEL, EASIEST ONE TELLS YOU WHICH TO MOVE!


On the easiest difficulty, you only learn about a single critter and puzzles only take two or three steps. **The game tells you which one to move and where it can go**, and you simply decide. A nice way to teach the puzzle and get started.

The game contains 5 difficulty levels, though, and higher difficulties ...

* Add more critters that move in unique ways (one at a time)
* Add more challenging maps where you really have to puzzle to make sure critters don't block each other's spaces.
* Add more freedom: instead of telling you "this turn, move the fox", you decide which animal to move yourself. (This requires two taps: pick animal, pick new space.)
* (Similarly, make the targets "generic": you must figure out yourself WHO should end up there.)
* (Maybe we can also have "intermediate" targets for pieces to pick up?)

@IDEA: When animating, make the pieces "hop" to their target _one space at a time_!



GENERATION ALGORITHM:

* Just place pieces at random spaces -> save these as their **targets**.
* Pick random moves.
  * Prefer spaces where another piece was before. (With some probability, not 100%)
  * Forbid moving the same piece twice in a row along the same axis. (It's fine if they move twice, but go in a different direction the second time.)
  * (With some probability, prefer _longer_ distances to travel?)
* Wherever pieces end up is their **starting position**. 
  * _Reverse_ the random moves we made -> that is our solution


# To-Do

## PuzzleFramework (THIS IS LATEST VERSION NOW)

* Allow setting the _scale_ of the `give_feedback` node (and other UI elements??)
* Create some reusable module for "react to click + hover on area" as I'm retyping that code again and again now ...
  * Yes, an `Area2D` that sends these signals, plus a `set_size` function for dynamic resizing of collision shape that I often do (and an `@export` variable to set this from editor manually)
* SOME WAY TO TRACK/SAVE PROGRESS? Like "how far did the player get?" or "what's the highest difficulty they solved?" or "how long does it take them on average to solve these puzzles (in terms of time/turns)?" => At least save settings right?

**@IDEA/@IMPROV: If we ever want to support "campaigns",** I could just save the seed + some crucial detail (like machine starting pos). I can then run a debug tool to just check if that crucial detail is still the same in all generated puzzles, protecting against accidental changes in earlier campaign puzzles.




# Difficulty Levels

## Easiest

CRITTERS: LEFT / RIGHT
PLAY: Targets specified, turns specified, you just say _where_ the current animal should go.

(The rule of "pieces can't share a space" should probably just be enabled at all times, right?)

## Easy

CRITTERS: UP / DOWN
PLAY: Targets specified, turns specified, you just say _where_ the current animal should go.

## Medium

CRITTERS: DIAGONAL
PLAY: Turns specified, you just say _where_ the current animal should go.

## Hard

CRITTERS: ANY ONE STEP / KNIGHT MOVEMENT
PLAY: Targets and turns up to you

## Hardest

CRITTERS: Something even funkier?
PLAY: ??