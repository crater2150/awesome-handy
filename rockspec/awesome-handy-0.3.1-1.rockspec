package = "awesome-handy"
version = "0.3.1-1"
source = {
   url = "git+https://github.com/crater2150/awesome-handy.git",
   tag = "v0.3.1"
}
description = {
   summary = "pop-up apps for awesomewm",
   detailed = [[
Handy is a module for [awesome](https://awesomewm.org/). It allows you to launch
a floating application, which can be shown and hidden with a keypress, similar
to drop-down terminals like guake or tilda, without the animation, but not
limited to terminals.
]],
   homepage = "https://github.com/crater2150/awesome-handy",
   license = "Apache-2.0"
}
dependencies = {
   "lua >= 5.2, < 5.5",
}
build = {
   type = "builtin",
   modules = {
      handy = "init.lua",
   }
}
