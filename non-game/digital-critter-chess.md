# Critter Chess

# To-Do

## Puzzle Generation/Play

@TODO: Do something with CAPTURING? Like actual Chess?

* Implementation:
  * Make move valid if already has piece _if it can capture_.
  * Add a `CommandCapture` that handles this (as the old piece is just gone, replaced by new one)
* Have some mystery animals do this?
* QUESTION: WHAT IS THE ACTUAL PURPOSE OF THIS? Because removing animals now simply means making the puzzle unsolvable ...
  * I _could_ add animals whose entire purpose is to be captured?
  * After moving such an animal to an empty space, pretend there was an animal there all along. (An animal with no home.)
  * _This can make the puzzle unsolvable though, as placing an animal there might ruin the moves of earlier animals passing by that space_.
* I _could_ change "capture" to happen by jumping _over_ animals. Then we "merely" need to ensure that any animals our mystery animal jumped over are removed + do _not_ have a home to visit.
* I _could_ make it twofold ---> capturing animals will _remove homes_ if they land there, and _remove pieces_ if they land on them. Through a combination of removing BOTH the piece and its home, you can still solve puzzles?
* Or I _could_ add animals that simply CAN'T MOVE. They stand on your home square or in the way, and the only way to pass through is to capture them?


@TODO: A Direction + Grouping puzzle game idea where the **direction** is **given** each turn. In other words, 

* Pieces don't have assigned movements.
* Each turn, you simply get an arrow that tells you how things must move now.
* You tap one animal => **all animals of that type now take one step in that direction!** (if they can)
* ====> THIS IS A DIFFERENT GAME -> **Dancing Dodo(e)s** or **Salsa Zoo!** or **Swingy Zoo!**



## Finishing

* Audio narration of direction you moved in
* Tutorial => Images + VoiceOver
* CREATE FINAL MYSTERY ANIMALS + ADD A LITTLE BOOKLET WITH HOW ALL THE "MYSTERY ANIMALS" MOVE!


## PuzzleFramework (THIS IS LATEST VERSION NOW)

* Allow setting the _scale_ of the `give_feedback` node (and other UI elements??)
* SOME WAY TO TRACK/SAVE PROGRESS? Like "how far did the player get?" or "what's the highest difficulty they solved?" or "how long does it take them on average to solve these puzzles (in terms of time/turns)?" => At least save settings right?

**@IDEA/@IMPROV: If we ever want to support "campaigns",** I could just save the seed + some crucial detail (like machine starting pos). I can then run a debug tool to just check if that crucial detail is still the same in all generated puzzles, protecting against accidental changes in earlier campaign puzzles.




## Discarded / Future To-Do

* I added the option to have collectibles spawn on top of homes. But it just looks mediocre and messy, so turned it off again.





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
