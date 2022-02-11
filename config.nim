#[
Foreground [3 + id + m
  Black   [30m
  Red     1
  Green   2
  Yellow  3
  Blue    4
  Magenta 5
  Cyan    6
  White   7
Background [4 + id + m
  Black   [40m
  Red     1
]#
const VALS = [
  # Blank
  "[47m   [40m", # Non-playable
  "[40m   ", # Playable
  # Player 1
  "[31m o ",
  "[31m @ ", # Queen
  "[31m[o]", # Select
  # Player 2
  "[37m o ",
  "[37m @ ", # Queen
  "[37m[o]"] # Select
const HSEP = "  +------------------------+\n"
const VSEP = '|'
const ALPHA = "    A  B  C  D  E  F  G  H\n"
