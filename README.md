# FPXJ

A small game by Tom Marks for the Playstation 2. Remixing and extending this game is
encouraged. Level editor included!

## Links

* [itch.io](#)

## How to Play

This game is playable on a **real Playstation 2** capable of running homebrew programs. It is also
playable in the PCSX2 emulator.

Instructions for how to play, as well as how to construct a playable package coming "soon"

## About

Started as part of Lisp Autumn Game Jam 2021, FPXJ is a small game with poor SEO to test
out the foundations of Playstation 2 game development. A majority of this game is written
in fennel and Lua, which calls into a minimal C layer for communicating to PS2 hardware.

If you are interested in PS2 game development, the Lua interfaces are designed to be
simple to read and easy to extend. You can build on top of my "draw2d" abstraction,
or dig into how it works and how individual GS commands (called GIFTags) are constructed.

