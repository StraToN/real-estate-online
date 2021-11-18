extends Node

const CONFIGURATION_FILE_DEFAULT_PATH = 'res://project.godot'
const CONFIGURATION_FILE_LOCALE_PATH = 'user://locale.godot'
const CONFIGURATION_FILE_PATH = 'user://configuration.godot.local'
const DELTA_THRESHOLD = 1.0

var DEFAULT_KEYS = {
  RealEstateOnline = {
    all = false,
    keys = []
  },

  audio = {
    all = false,
    keys = ['soundfx_volume', 'music_volume']
  },

  display = {
    all = false,
    keys = []
  }
}

var LOCALE_KEYS = {
  RealEstateOnline = {
    all = false,
    keys = ['locale']
  }
}

signal configuration_saved()

var mouse_mode_state = null

var __saving = false
var __delta_acc = 0

func _ready():
  # Initiate config_file
  var config_file = ConfigFile.new()

  # Load the default values first (in case of corrupted configuration.cfg file)
  config_file.load(CONFIGURATION_FILE_DEFAULT_PATH)

  load_keys(config_file)

  var status = config_file.load(CONFIGURATION_FILE_PATH)

  if status == OK:
    load_keys(config_file)

  status = config_file.load(CONFIGURATION_FILE_LOCALE_PATH)

  if status == OK:
    load_keys(config_file, LOCALE_KEYS)

  # Set resolution_manager
  # resolution_manager.deferred_update_resolution()
  _update_mouse_mode()

  # Update the last savegame
  # save_manager.connect('_game_saved', self, 'update_last_game')

func load_keys(config_file, keys_to_load = DEFAULT_KEYS):
  for section_name in keys_to_load:
    if config_file.has_section(section_name):
      var section_config = keys_to_load[section_name]
      var keys = config_file.get_section_keys(section_name)

      if not section_config.all:
        keys = section_config.keys

      for key in keys:
        if config_file.has_section_key(section_name, key):
          var value = config_file.get_value(section_name, key)

          globals_manager.set_pair(key, value)
        else:
          logger.warning('The section/key "%s/%s" has not been found', [section_name, key])
    else:
      logger.warning('The section "%s" has not been found', [section_name])

func queue_save():
  __delta_acc = DELTA_THRESHOLD
  set_process(true)

func _process(delta):
  __delta_acc -= delta

  if __delta_acc < 0:
    set_process(false)
    save()

func save(file = CONFIGURATION_FILE_PATH, keys_to_save = DEFAULT_KEYS):
  if __saving:
    return false

  __saving = true

  var config_file = ConfigFile.new()

  for section_name in keys_to_save:
    var section_config = keys_to_save[section_name]
    var keys = []

    if section_config.has('keys'):
      keys = section_config.keys

    for key in keys:
      var value = globals_manager.get_pair(key)

      config_file.set_value(section_name, key, value)

  config_file.save(file)

  # Set resolution_manager
  # resolution_manager.deferred_update_resolution()
  _update_mouse_mode()
  call_deferred('emit_signal', 'configuration_saved')
  __saving = false

  return true

func update_last_game(savegame):
  logger.debug('Update last save game')

  globals_manager.set_pair('lastsavegame', savegame)
  save()

func inc_session():
  var session = globals_manager.get_pair('session')

  globals_manager.set_pair('session', session + 1)

  call_deferred('save')

  return session + 1

func _update_mouse_mode():
  # Do not update if there is nothing to update
  if mouse_mode_state != globals_manager.get_pair('confined_cursor'):
    mouse_mode_state = globals_manager.get_pair('confined_cursor')

    if globals_manager.get_pair('confined_cursor'):
      Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
