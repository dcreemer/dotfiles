# Local Hammerspoon configuration

I use [Hammerspoon](https://www.hammerspoon.org) in a few different macOS
automation ways:

## URL Launcher

I maintain a mapping of URL patterns to applications that I want to handle them
with. Most URLs are handles by the default browser, but some are handled by a
specific application. For example, I use the Zoom app to handle `zoom.us` URLs.
See [the
source](https://github.com/dcreemer/dotfiles/blob/main/dot_hammerspoon/browsers.lua)
for more details.

## Window management

I define hotkeys to move and resize windows, based on a percentage of the
screen. See
[here](https://github.com/dcreemer/dotfiles/blob/main/dot_hammerspoon/windows.lua)
for the specifics.

## App-specific functionality

I've built a module to control Bear.app, and added the ability to create notes
from templates, add backlinks to notes, and maintain a daily journal. See
[here](https://github.com/dcreemer/hammerspoon-bear) for my implementation of
that.

## Key Bindings

Global and application-specific key bindings are defined in
[keymap.lua](https://github.com/dcreemer/dotfiles/blob/main/dot_hammerspoon/keymap.lua).