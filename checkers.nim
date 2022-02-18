# import strutils
import terminal

# Visit "nim-lang.org/docs/terminal.html#7" for color values.
const STYLE = [
  "[47m   [40m", # Fake blank
  "   ",

  "[31m o ",      # P1
  "[31m[o]",      # Regular select
  "[31m @ ",      # Queen
  "[31m[@]",      # Queen select

  "[37m o ",
  "[37m[o]",
  "[37m @ ",
  "[37m[@]"]
const HSEP = "  +------------------------+\n"
const VSEP = '|'

var pieces: array[32, Natural]
for i in 0..11: pieces[i] = 6
for i in 12..19: pieces[i] = 1
for i in 20..31: pieces[i] = 2

# Instead of having actual empty cells, we add colored spaces before
# or after real cells to create an illusion. This saves space, time,
# and can correct an empty selection.
var board = newStringOfCap(1000)
proc compileBoard() =
  board = "    A  B  C  D  E  F  G  H\n" & HSEP
  for i in 0..7:
    board.add($(i+1) & VSEP & "[1m") # row + bold style

    for j in 0..3:
      if i mod 2 == 0: board.add(STYLE[0] & STYLE[pieces[i*4+j]])
      else: board.add(STYLE[pieces[i*4+j]] & STYLE[0])

    board.add("[0m" & VSEP & '\n') # reset style

proc convertToId(s: string): Natural =
  result = (int(s[1]) - 49) * 4 + ( # Row * cells/row, int('1') = 49
    int(s[0]) - 97) div 2 # Column, int('a') = 97

var sel: Natural
var player = '2'
proc testSel(base: Natural): bool =
  if player == '1':
    if pieces[base] > 1 and pieces[base] < 6: result = true
  elif pieces[base] > 5: result = true

var offset: Natural
proc testPos(pos: varargs[int]): bool =
  let halfLen = len(pos) div 2
  case pieces[sel]
  of 2: # Regular select, player 1
    for i in 0..halfLen-1:
      if offset == pos[i]: result = true
  of 6: # Same for player 2
    for i in halfLen..len(pos)-1:
      if offset == pos[i]: result = true
  else: # Queen
    for p in pos:
      if offset == p: result = true

proc testCapture(base: Natural): bool =
  if player == '1':
    if pieces[base] == 6 or pieces[base] == 8: result = true
  elif pieces[base] == 2 or pieces[base] == 4: result = true

var target: Natural
proc testTarget(): bool =
  offset = target - sel

  if offset > -6 and offset < 6: # Slide
    # Last cell on even row and first cell on odd row have same reqs.
    if (sel+5) div 2 mod 4 == 0: result = testPos(-4, 4)
    elif sel div 4 mod 2 == 0: result = testPos(-3, -4, 4, 5) # Even row
    else: result = testPos(-4, -5, 3, 4) # Odd row
  else: # Capture
    if sel mod 4 == 0: result = testPos(-7, 9) # Left wall
    if sel mod 4 == 3: result = testPos(-9, 7) # Right wall
    else: result = testPos(-7, -9, 7, 9)

    if sel div 4 mod 2 == 0:
      result = testCapture(sel + (offset+1) div 2) # Even row
      if result: pieces[sel + (offset+1) div 2] = 1
    else:
      result = testCapture(sel + (offset-1) div 2)
      if result: pieces[sel + (offset-1) div 2] = 1

proc testQueen() =
  for i in 0..31:
    if i div 4 == 0:
      if pieces[i] == 2: pieces[i] = 4
    if i div 8 == 7:
      if pieces[i] == 6: pieces[i] = 8

# You have to capture a piece.
# var requiredMoves = newSeq[seq[int]](5)

# TODO: Perhaps we could implement an action-based system,
# where the user inputs a command. This way, we could have
# an 'exit' command, and the player that issues it loses.
proc checkGameOver(): bool =
  result = true
  for i in 0..31:
    if pieces[i] > 1: result = false

# pieces[convertToId("a6")] = 4
var tryAgain = false
while not checkGameOver():
  testQueen()
  compileBoard()
  eraseScreen()

  if tryAgain: tryAgain = false
  elif player == '1': player = '2'
  else: player = '1'

  stdout.write(board, HSEP, "Player ", player, "\nSelect: ")
  sel = convertToId(stdin.readLine())
  if not testSel(sel): tryAgain = true; continue

  inc(pieces[sel])
  compileBoard()
  dec(pieces[sel])
  eraseScreen()

  stdout.write(board, HSEP, "Target: ")
  target = convertToId(stdin.readLine())
  if not testTarget(): tryAgain = true; continue

  pieces[target] = pieces[sel]
  pieces[sel] = 1
