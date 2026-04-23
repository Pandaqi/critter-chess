# Critter Chess

# To-Do

* Tutorial: Images
* Mystery Critters: Create example images of all mystery animal movements => Export PDF and include


## PuzzleFramework (THIS IS LATEST VERSION NOW)

* Allow setting the _scale_ of the `give_feedback` node (and other UI elements??)
* SOME WAY TO TRACK/SAVE PROGRESS? Like "how far did the player get?" or "what's the highest difficulty they solved?" or "how long does it take them on average to solve these puzzles (in terms of time/turns)?" => At least save settings right?

**@IDEA/@IMPROV: If we ever want to support "campaigns",** I could just save the seed + some crucial detail (like machine starting pos). I can then run a debug tool to just check if that crucial detail is still the same in all generated puzzles, protecting against accidental changes in earlier campaign puzzles.


## Discarded / Future To-Do

* I added the option to have collectibles spawn on top of homes. But it just looks mediocre and messy, so turned it off again.
* One mystery critter (Chick) used to have the "range" rule: only allowed to move 2 spaces at most. This ended up not being as interesting as other ideas though.




# Difficulty Levels

## Easiest

TUTORIAL = "Animals move in the direction of their arrow. Click an animal, then click where it should go. Bring all animals home!"

CRITTERS: 
Raccoon, Fox, Bear, Deer

RULES:
pieces_go_as_far_as_they_can = false
pieces_can_go_backward = false
pieces_can_jump = false
allow_anonymous_homes = false
place_collectibles = false


## Easy

TUTORIAL = "From now on, animals can also move backwards."

CRITTERS: 
Raccoon, Fox, Bear, Deer

RULES:
pieces_go_as_far_as_they_can = false
pieces_can_go_backward = true
pieces_can_jump = false
allow_anonymous_homes = false
place_collectibles = false


## Medium

TUTORIAL = "From now on, you also need to collect all diamonds, by moving into the space from the direction shown. Animals can move as far as they want now."

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

TUTORIAL = "This level has no new rules, only new animals and bigger boards."

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

TUTORIAL = "From now on, pieces can jump over other pieces! Also beware the tricky horse; it moves once straight and once diagonal."

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

## Mystery Animals

_See PDF with solutions for latest version + illustrated examples of how they move._

[x] HORSE ---> Moves like knight in chess

[x] SNAIL ---> All; can't jump
[x] OWL ---> Diagonal; Can jump over MULTIPLE pieces (4 atm)
[x] FROG ---> Orthogonal; MUST jump over another piece
[x] WHALE ---> Orthogonal; MUST move at least 2 spaces
[x] MOUSE ---> Diagonal; Does not want to move at all if another piece is adjacent to them
[x] CHICK ---> All; can move AT MOST 2 spaces
[x] BUNNY ---> Orthogonal; Only wants to move if there's another piece in the same row or column.
[x] BUTTERFLY --->

IDEAS:

* Teleport to edge of map? 
* Go one way then another? LEFT LEFT UP UP ===> Wait a minute, reversing a sequence will just always end up at the same tile :p
* Can only move if starts/ends next to my own type ===> force placement in pairs
* Can't go backwards + ??
* If at the end of the map, only allowed to go _into_ the map (not _along_ the edge)

## Leftovers

DONKEY

LADYBUG
BIRD

OWL_ALT
BUNNY_ALT


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
