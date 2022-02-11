import strutils
include "config.nim"

#[
A board of checkers is 8x8, but half are non-playable. We add colored
spaces before or after playable cells to create an illusion. Wall cells
need styling as well. To combine both, we store the style before a cell
in [0], and after it in [1], determined at compile-time.
]#
const STYLE = (
  var style: array[32, array[2, string]];
  for i in 0..31:
    # Left wall (Start bold)
    if i mod 4 == 0: style[i][0] = $((i div 4)+1) & ' ' & VSEP & "[1m";

    if i div 4 mod 2 == 0: style[i][0].add(VALS[0])
    else: style[i][1] = VALS[0];

    # Right wall (Reset style)
    if (i+1) mod 4 == 0: style[i][1].add("[0m|\n");
  style)

var board: array[32, Natural] # Here are the actual cell values.

for i in 0..11: board[i] = 2
for i in 12..19: board[i] = 1
for i in 20..31: board[i] = 5

var outStr = newStringOfCap(1000)
proc drawBoard() =
  outStr = ALPHA & HSEP
  for i in 0..31: outStr.add(STYLE[i][0] & VALS[board[i]] & STYLE[i][1])
  stdout.write(outStr, HSEP)

var id: Natural
proc convertToId(s: string) =
  # Fast way to convert chars to nums, and nums to id.
  # It also corrects a blank selection to neighbours.
  id = (int(s[1]) - 49) * 4 + (int(toUpperAscii(s[0])) - 65) div 2

var player = '2'
proc nextPlayer() =
  if player == '1': player = '2'
  else: player = '1'

var tryAgain = false
proc isLegalSelect(): bool =
  if player == '1':
    if board[id] > 1 and board[id] < 5: result = true
  elif board[id] > 4: result = true

proc isLegalTarget(): bool =
  # TODO: Add logic
  if board[id] < 1: result = true # Can't be non-blank
  if player == '1':
    if board[id] != 3: # Not queen
      discard

var tempVal: Natural
while true:
  drawBoard()

  if tryAgain: tryAgain = false
  else: nextPlayer()

  stdout.write("Player ", player, "\nSelect: ")
  convertToId(stdin.readLine())
  if id > 32 or not isLegalSelect():
    tryAgain = true; continue

  # Select cell.
  tempVal = board[id]
  if player == '1': board[id] = 4
  else: board[id] = 7
  echo id
  drawBoard()
  board[id] = tempVal
  tempVal = id

  stdout.write("Target: ")
  convertToId(stdin.readLine())
  if id > 32 and not isLegalTarget():
    tryAgain = true; continue

  board[id] = board[tempVal]
  board[tempVal] = 1