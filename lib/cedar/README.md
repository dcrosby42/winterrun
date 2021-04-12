# Cedar 

A material for building games on top of Gosu.

## Modules

- `new_state`
- `load_resources(state, res)`
- `update(state, input, res) => state`
- `draw(state, output, res)`

## State

## Input

- `time`
  - `time.dt` - delta time. time elapsed this tick (floating point seconds)
  - `time.dt_millis` - delta time. time elapsed this tick (milliseconds)
  - `time.t` - game time in seconds (floating point)
  - `time.millis` - game time in milliseconds (== Gosu.milliseconds)
- `keyboard` - introspect state of keyboard, based on Gosu keyboard sumbols, eg, `Gosu::KB_A`, `Gosu::KB_LEFT_SHIFT`
  - `keyboard.down?(key)`
  - `keyboard.pressed?(key)`
  - `keyboard.released?(key)`
  - `keyboard.shift?(key)`
  - `keyboard.control?(key)`
  - `keyboard.alt?(key)`
  - `keyboard.meta?(key)`
  - `keyboard.any?`
- `mouse`
  - `mouse.x`
  - `mouse.y`
- `window` - the current `Gosu::Window`. Intended for status/size info read-only.

For dev:

- `did_reload`
- `did_reset`

## Resources


Cedar::ResourceLoader
Cedar::Resources
  TODO: #load - option to be lazy or do immediate construction

WIP
TEST - Cedar::Resources::GridSheetSprite
MOVE/REIMPL - Cedar::Resources::ImageSprite 
TEST - Cedar::Resources::CyclicSpriteAnimation


### Types

file
data
image
sprite
animation
? font
? sound
? music



- `sprites`
  - `sprites.load(sprint_info|filename)` - filenames are supposed to be json files rooted under res/files/
- `anims`
- `images`
- `files`
- `fonts`
  - `fonts.load(font_info)`

## Output

- `output`
  - `output.graphics` - The root `Cedar::Draw::Sequence` to send drawables to.

### Drawables

- `Cedar::Draw::Rect`
- `Cedar::Draw::Line`
- `Cedar::Draw::Image`
- `Cedar::Draw::SheetSprite`
- `Cedar::Draw::Label`

- `Cedar::Draw::Sequence`