extends MarginContainer

func _ready():
  GodotErrorHandler.connect('error_threw', _handle_error)

  logger.debug('Welcome to Real Estate Online, the multiplayer board game')

  $container/top/original.connect('pressed', _original_game_pressed, [], CONNECT_ONESHOT)
  $container/top/classic.connect('pressed', _classic_game_pressed, [], CONNECT_ONESHOT)
  $container/bottom/option.connect('pressed', _option_pressed, [])
  $container/bottom/quit.connect('pressed', _quit_pressed, [], CONNECT_ONESHOT)
  $container/bottom/language.connect('pressed', _language_pressed, [], CONNECT_ONESHOT)

func _handle_error(error_object):
  logger.debug('At %s (%s:%s) %s', [
    error_object.source_func,
    error_object.source_file,
    error_object.source_line,
    error_object.error
  ])

func _classic_game_pressed():
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)
  pass

func _original_game_pressed():
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)
  pass

func _option_pressed():
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  # TODO
  # Ensure we cannot double click on options, and we need to reconnect
  # the button's event
  pass

func _language_pressed():
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  # TODO
  # Ensure we cannot double click on languages, and we need to reconnect
  # the button's event
  pass

func _quit_pressed():
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  get_tree().call_deferred('quit')
