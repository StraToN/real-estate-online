extends Node

var RESOLUTION_OPTIONS = {
  '5120 x 2880': [5120, 2880],
  '3840 x 2160': [3840, 2160],
  '3200 x 1800': [3200, 1800],
  '2560 x 1440': [2560, 1440],
  '2432 x 1368': [2432, 1368],
  '1920 x 1080': [1920, 1080],
  '1824 x 1026': [1824, 1026],
  '1600 x 900': [1600, 900],
  '1520 x 855': [1520, 855],
  '1366 x 768': [1366, 768],
  '1280 x 720': [1280, 720],
  '1216 x 684': [1216, 684],
  '1152 x 648': [1152, 648],
  '1024 x 576': [1024, 576]
}

var LOCALES = [{
  'key': 'English',
  'value': 'en',
  'icon': 'res://theme/icon/flags/en-106x64.tex'
}, {
  'key': 'Francais',
  'value': 'fr',
  'icon': 'res://theme/icon/flags/fr-106x64.tex'
}]

var __global = {}

signal key_updated(name)

func _ready():
  reset()

func reset():
  # Load the default locale by default
  set_pair('locale', OS.get_locale().left(2))

  set_pair('soundfx_volume', 0.5)
  set_pair('music_volume', 0.5)
  set_pair('confined_cursor', false)

# Note
# Since Godot 3, we cannot override any native functions, which include `set` and `get`.
# Thank you
func set_pair(key, value):
  if __global.has(key):
    logger.debug('Overtwriting key %s', [key])

  else:
    logger.debug('Writing key %s', [key])

  __global[key] = value

  emit_signal('key_updated', key)

# Note
# Since Godot 3, we cannot override any native functions, which include `set` and `get`.
# Thank you
func get_pair(key, default_value = null):
  return __global.get(key, default_value)

func clear():
  __global.clear()

  # Reset
  reset()

func empty():
  return __global.empty()

func erase(key):
  __global.erase(key)

func has(key):
  return __global.has(key)

func has_all(p_keys):
  return __global.has_all(p_keys)

func keys():
  return __global.keys()

func parse_json(text):
  __global.parse_json(text)

func size():
  return __global.size()

func to_json():
  return __global.to_json()

func values():
  return __global.values()

func get_locale():
  return get('locale')
