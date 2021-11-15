@tool
extends PathFollow3D

const constant_utils = preload('res://script/util/constants.gd')
const DICE_SCENE = preload('res://scene/dice/main.tscn')

const NUMBER_OF_CASES = 36
const ANIMATION_DURATION = 0.667
const PLAYER_POSITIONS = [
  Vector3(0.041, -0.002, -0.031),
  Vector3(0.158, -0.002, -0.045),
  Vector3(0.059, -0.002, 0.024),
  Vector3(0.172, -0.002, 0.015)
]

const PANEL_POSITIONS = [
  Vector2(0.0, 0.0),
  Vector2(1920 - 256, 0.0),
  Vector2(1920 - 256, 1080 - 96.0),
  Vector2(0.0, 1080 - 96.0)
]

signal player_end_of_turn(player_index)
signal player_bankrupt(player_index)
signal player_won(player_index)

var __name = 0
var __player_type = constant_utils.PLAYER_TYPE.HUMAN_LOCAL

func _ready():
  var player_index = get_index()

  $origin.position = PLAYER_POSITIONS[player_index]
  $canvas/panel.rect_position = PANEL_POSITIONS[player_index]

func set_player_data(player_data):
  __name = player_data.name

  $canvas/panel/label.set_text(player_data.name)

  if player_data.human and player_data.local:
    __player_type = constant_utils.PLAYER_TYPE.HUMAN_LOCAL

  elif player_data.human and not player_data.local:
    __player_type = constant_utils.PLAYER_TYPE.HUMAN_REMOTE

  elif not player_data.human and not player_data.local:
    __player_type = constant_utils.PLAYER_TYPE.COMPUTER_LOCAL

  elif not player_data.human and not player_data.local:
    __player_type = constant_utils.PLAYER_TYPE.COMPUTER_REMOTE

func begin_turn():
  # Instanciate dices
  # Change camera
  var dice_scene_instance = DICE_SCENE.instantiate()
  var root_node = get_tree().get_nodes_in_group('root_node')[0]

  dice_scene_instance.set_player_type(__player_type)
  dice_scene_instance.connect('throw_value', _dice_threw, [], CONNECT_ONESHOT)
  root_node.call_deferred('add_child', dice_scene_instance)

func _dice_threw(dice_1, dice_2):
  var number_of_cases = dice_1 + dice_2
  var tween = create_tween()

  tween.set_parallel(true)
  tween.tween_property(self, 'unit_offset', unit_offset + (number_of_cases * 1.0) / NUMBER_OF_CASES, ANIMATION_DURATION).set_trans(Tween.TRANS_SINE)

  if dice_1 == dice_2:
    tween.tween_callback(begin_turn).set_delay(ANIMATION_DURATION)

  else:
    tween.tween_callback(_play_case).set_delay(ANIMATION_DURATION)

  tween.play()

func _play_case():
  var case_number = int(unit_offset * NUMBER_OF_CASES)

  # TODO
  # Not yet implemented
  logger.debug('case_number: %s', [case_number])
  _end_of_turn()

func _end_of_turn():
  # TODO
  # Not yet implemented
  emit_signal('player_end_of_turn', get_index())
