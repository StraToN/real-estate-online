extends MarginContainer

func _ready():
  _reset(false)

  $container/panelContainer/container/bottom/back.connect('pressed', _close, [], CONNECT_ONESHOT)
  $container/panelContainer/container/bottom/reset.connect('pressed', _reset)
  $container/panelContainer/container/bottom/apply.connect('pressed', _apply, [], CONNECT_ONESHOT)

func _close():
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  # TODO
  # Previous scene

func _reset(play_sound = true):
  if play_sound:
    soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  $container/panelContainer/container/music/value.set_value(globals_manager.get_pair('music_volume') * 100.0)
  $container/panelContainer/container/soundfx/value.set_value(globals_manager.get_pair('soundfx_volume') * 100.0)

func _apply():
  globals_manager.set_pair('music_volume', $container/panelContainer/container/music/value.get_value() / 100.0)
  globals_manager.set_pair('soundfx_volume', $container/panelContainer/container/soundfx/value.get_value() / 100.0)

  configuration_manager.queue_save()

  _close()
