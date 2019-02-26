# awesome-handy - Popup programs for awesomewm

handy is a module for [awesome](https://awesomewm.org/), that allows you to open
and hide a floating program with a keybinding. Main features:

- spawns an instance per screen or can be bound for a specific screen
- instances are remembered across awesome restarts, so pressing your key won't
  start a second instance but reuse the previous one
- placement via `awful.placement` API

*handy requires awesome 4.0+*

## Installation

Put this repository somewhere in the lua search path for awesome. If your
awesome configuration is managed by git, I recommend adding this repo as a git
submodule:

```git submodule add https://github.com/crater2150/awesome-handy.git handy ```

Then, in your `rc.lua`:

```local handy = require("handy")```

## Usage

The following example spawns an urxvt instance in the center of the screen, 90%
wide and 70% high when pressing <kbd>F12</kbd> the first time, after that it
toggles its visibility:

```lua
awful.key({ }, "F12", function ()
	handy("urxvt", awful.placement.centered, 0.9, 0.7)
end ),
```

The following parameters are accepted:  
`handy(prog, placement, width, height, options, screen)`

- `prog`: the only mandatory parameter, the command to run
- `placement`: controls the position of the window, see [`awful.placement`](https://awesomewm.org/apidoc/libraries/awful.placement.html)
- `width`, `height`: the size of the program. Values ≤ 1 are interpreted as
  percentage of screen size, values above 1 are interpreted as pixel sizes
- `options`: arguments passed to awful.placement
- `screen`: the screen to use. if not given, defaults to the currently focused
  screen, so each screen will have its own instance
