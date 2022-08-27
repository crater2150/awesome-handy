# awesome-handy - Popup programs for awesomewm

handy is a module for [awesome](https://awesomewm.org/), that allows you to open
and hide a floating program with a keybinding. Main features:

- spawns an instance per screen or can be bound for a specific screen
- instances are remembered across awesome restarts, so pressing your key won't
  start a second instance but reuse the previous one
- placement via `awful.placement` API

*handy requires awesome 4.0+*

## Installation

Put this repository somewhere in the lua search path for awesome.
If you're using [LuaRocks](https://luarocks.org/), you can install it via
```
luarocks install --local awesome-handy
```

Alternatively, if your awesome configuration is managed by git, you can add
this repo as a git submodule:

```
git submodule add https://github.com/crater2150/awesome-handy.git handy
```

Otherwise just clone it into your configuration directory.


Then, in your `rc.lua`:

```lua
local handy = require("handy")
```

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
`handy(prog, placement, width, height, options, screen, class)`

- `prog`: the only mandatory parameter, the command to run
- `placement`: controls the position of the window, see [`awful.placement`](https://awesomewm.org/apidoc/libraries/awful.placement.html)
- `width`, `height`: the size of the program. Values ≤ 1 are interpreted as
  percentage of screen size, values above 1 are interpreted as pixel sizes
- `options`: arguments passed to awful.placement
- `screen`: the screen to use. if not given, defaults to the currently focused
  screen, so each screen will have its own instance

  You can also set this to the string `"single"` for a client, that should only
  have a single instance (instead of one per screen). The client will always be
  shown on the currently focused screen, even if it was opened on another
  screen before (note that if the client is currently shown on an unfocused
  screen, you'll have to toggle it twice to move it to the current screen).
- `class`: If given, must be the class or instance name of the window. Will
  enable using the fallback method for programs not supporting startup
  notification ([see below](#programs-without-startup-notification))


## Programs without startup notification

The default method for `handy` to detect which window is supposed to toggle is
to use `awful.spawn` with a callback. This callback mechanism works by passing
a startup id to the program, which only works with programs supporting the
[Startup Notification spec](https://www.freedesktop.org/wiki/Specifications/startup-notification-spec/).

When specifying the window instance name, handy will use a fallback method for
the callback, which has the drawback, that if you start another program with
the same class/instance during the startup of the first, the one which displays
its window earlier will become the pop-up. If your program supports it, use
a custom window instance that is unlikely to be used by other windows (e.g.
"handy" + program name) and don't double press the key for handy.
