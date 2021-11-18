extends Node

enum VOICE_ID {
  UI_CLICK
}

var FX = {
  UI_CLICK = {
    loop_mode = AudioStreamSample.LOOP_DISABLED,
    name = ['click-0'],
    polyphony = 1
  }
}

const GLOBAL_KEY_FX_VOLUME = 'soundfx_volume'
const BUS_NAME = 'SoundFX'

func _ready():
  for item_data in FX.values():
    for item_data_name in item_data.name:
      var asp_instance = AudioStreamPlayer.new()
      var audio_stream_sample = load('res://assets/sound/%s.wav' % [
        item_data_name
      ])

      audio_stream_sample.set_loop_mode(item_data.loop_mode)
      asp_instance.set_bus(BUS_NAME)
      asp_instance.set_stream(audio_stream_sample)
      asp_instance.autoplay = false
      asp_instance.set_name(item_data_name)
      asp_instance.set_volume_db(0.1)
      asp_instance.max_polyphony = item_data.polyphony

      add_child(asp_instance)

  update_fx_volume()
  globals_manager.connect('key_updated', key_updated, [], CONNECT_DEFERRED)

func key_updated(key_name):
  if GLOBAL_KEY_FX_VOLUME == key_name:
    update_fx_volume()

func update_fx_volume():
  var value = linear2db(globals_manager.get_pair(GLOBAL_KEY_FX_VOLUME, 0.5))
  var bus_index = AudioServer.get_bus_index(BUS_NAME)

  AudioServer.set_bus_volume_db(bus_index, value)

func play_sound(fx_item, pitch_scale = 1.0):
  var index = randi() % fx_item.name.size() if fx_item.name.size() > 0 else 0
  var sound_node = get_node(fx_item.name[index])

  sound_node.set_pitch_scale(pitch_scale)
  sound_node.play()

# set_key_value
# get_key_value
