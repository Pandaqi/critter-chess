# Critter Chess

# To-Do

## Puzzle Generation/Play






## Visuals

* Show the ANIMAL ORDER + HIGHLIGHT CURRENT ONE.
  * If player picks the animal, these sprites just switch to general flowers or something to indicate turns?
  * Have a **setting** to make a "max turns" optional?
  * Also turn **allow anonymous homes** into a setting? (It actually makes the puzzle much easier I've seen ... Does have the nice bonus of not needing to see the TYPE of the home ever when obscured)
* Show ALL arrows for where a piece can move
* Find solution for **not being able to see home type below animal**
  * Is there a way to also **add collectibles to homes**? Because our algorithm prefers putting other pieces on your homes, and if we can place collectibles then we actually have a good _reason_ to go there!
  * **THIS IS OUR BIGGEST PROBLEM RIGHT NOW**
  * **At the very least, HIGHLIGHT all possible homes when a piece of that type is selected!**
    * I probably want to use the four corners. Show the type on all four. Show type on 2, direction on 2, if there's also a collectible there.
    * Otherwise we can put a very obvious circle/panel in _front_ of the square (at the bottom) showing the type and stuff.
    * _Just try both, maybe even allow people to set this themselves_.
* Pieces more lively
* Appear/disappear
* Fake move tween on executing turn
  * If the move is a STRAIGHT LINE, make the pieces "hop" to their target _one space at a time_!
* Dotted rectangles on possible squares? Glow? Flowers around edges? Some other more subtle effect to indicate this?
* Several different forest backgrounds?
* If we _do_ keep homes around after completing them, then it should clearly change the visual of home + pawn to indicate "this one is in the right place!"
  * Change the tile below to a third type?
  * Do a little happy hop?
* FIX: Reset/refresh piece + target selection UI if you UNDO while in the midst of that.
* CREATE FINAL MYSTERY ANIMALS + ADD A LITTLE BOOKLET WITH HOW ALL THE "MYSTERY ANIMALS" MOVE!
* React to player HOVER. (Make critter transparent to show what's on the cell beneath them??)
* QOL: Keep the same piece selected as your last move (by default; can turn this off)?
* TWEAK: Maybe lower collectible probability on Medium difficulty? SHOULD it have collectibles?

## Finishing

* Audio narration of direction you moved in
* Tutorial => Images + VoiceOver



## PuzzleFramework (THIS IS LATEST VERSION NOW)


* Allow setting the _scale_ of the `give_feedback` node (and other UI elements??)
* SOME WAY TO TRACK/SAVE PROGRESS? Like "how far did the player get?" or "what's the highest difficulty they solved?" or "how long does it take them on average to solve these puzzles (in terms of time/turns)?" => At least save settings right?

**@IDEA/@IMPROV: If we ever want to support "campaigns",** I could just save the seed + some crucial detail (like machine starting pos). I can then run a debug tool to just check if that crucial detail is still the same in all generated puzzles, protecting against accidental changes in earlier campaign puzzles.






## Notes

A bunch of animals. Each one moves in a _unique way_ (inspired by chess but simplified): one moves horizontal, one vertical, one diagonal, one hops, etcetera.

You simply need to get them all to target squares. => Click on one, it highlights your possible squares, click the desired one to move. => NO THIS IS LATER DIFFICULTY LEVEL, EASIEST ONE TELLS YOU WHICH TO MOVE!


On the easiest difficulty, you only learn about a single critter and puzzles only take two or three steps. **The game tells you which one to move and where it can go**, and you simply decide. A nice way to teach the puzzle and get started.

The game contains 5 difficulty levels, though, and higher difficulties ...

* Add more critters that move in unique ways (one at a time)
* Add more challenging maps where you really have to puzzle to make sure critters don't block each other's spaces.
* Add more freedom: instead of telling you "this turn, move the fox", you decide which animal to move yourself. (This requires two taps: pick animal, pick new space.)
* (Similarly, make the targets "generic": you must figure out yourself WHO should end up there.)
* (Maybe we can also have "intermediate" targets for pieces to pick up?)





# Animals

## Easiest

[x] RACCOON = Right
[x] FOX = Left
[x] BEAR = Up
[x] DEER = Down

## Medium/Hard?

[x] SQUIRREL = Diagonal Up
[x] HEDGEHOG = Diagonal Down
[x] CAT = Diagonal Both
[x] BEAVER = Orthogonal All
[x] GOAT = All directions

## What to do with these?

BUNNY
DONKEY

LADYBUG
FROG
BUTTERFLY
BIRD

OWL_ALT
BUNNY_ALT



IDEAS:

* Teleport to edge of map? 
* Go one way then another? LEFT LEFT UP UP ===> Wait a minute, reversing a sequence will just always end up at the same tile :p
* "Can only move if there's someone/noone in same row/column" (or the inverse: can NOT move if row/column shared)
* Can only move if starts/ends next to my own type ===> force placement in pairs
* Can't go backwards + ??
* If at the end of the map, only allowed to go _into_ the map (not _along_ the edge)


## Mystery Animals

[x] HORSE ---> Moves like knight in chess

[x] SNAIL ---> All; can't jump
[x] OWL ---> Diagonal; Can jump over MULTIPLE pieces (4 atm)
[x] FROG ---> Orthogonal; MUST jump over another piece
[x] WHALE ---> Orthogonal; MUST move at least 2 spaces
[x] MOUSE ---> Diagonal; Does not want to move at all if another piece is adjacent to them
[x] CHICK ---> All; can move AT MOST 2 spaces






# Difficulty Levels

## Easiest

CRITTERS: 
Raccoon, Fox, Bear, Deer

RULES:
pieces_go_as_far_as_they_can = false
pieces_can_go_backward = false
pieces_can_jump = false
allow_anonymous_homes = false
place_collectibles = false


## Easy

CRITTERS: 
Raccoon, Fox, Bear, Deer

RULES:
pieces_go_as_far_as_they_can = true
pieces_can_go_backward = false
pieces_can_jump = false
allow_anonymous_homes = false
place_collectibles = false


## Medium

CRITTERS: 
Raccoon, Fox, Bear, Deer
Squirrel, Hedgehog,

RULES:
pieces_go_as_far_as_they_can = true
pieces_can_go_backward = true
pieces_can_jump = false
allow_anonymous_homes = false
place_collectibles = false


## Hard

CRITTERS:
Raccoon, Fox, Bear, Deer
Squirrel, Hedgehog, 
Cat, Beaver, Goat

RULES:
pieces_go_as_far_as_they_can = true
pieces_can_go_backward = true
pieces_can_jump = false
allow_anonymous_homes = false
place_collectibles = true


## Hardest

CRITTERS:
Raccoon, Fox, Bear, Deer
Squirrel, Hedgehog, Cat, Beaver, Goat
Horse (Knight)

RULES:
pieces_go_as_far_as_they_can = true
pieces_can_go_backward = true
pieces_can_jump = true
allow_anonymous_homes = true
place_collectibles = true
