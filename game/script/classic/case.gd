extends Node3D

const NUMBER_OF_CASES = 36
const BOARD_ANGLE = 360.0

const constant_utils = preload('res://script/util/constants.gd')
const number_utils = preload('res://script/util/number.gd')
const static_data = preload('res://data/classic.gd')

var __data
var __wonder_data

var __game_data = {
  owner = null,
  houses = 0,
  number_of_owners = 0,
  festival = false
}

func _ready():
  rotate_y(deg2rad((-BOARD_ANGLE / NUMBER_OF_CASES) * get_index() + (BOARD_ANGLE / (NUMBER_OF_CASES * 2))))

  $sprite/subViewport/price.set('theme_override_colors/font_shadow_color', __data.color.shadow)
  $sprite/subViewport/price.visible = false
  $sprite/subViewport/name.set('theme_override_colors/font_shadow_color', __data.color.shadow)

  if __data.type == constant_utils.CASE_TYPE.PROPERTY:
    $sprite/subViewport/price.set_text(number_utils.format_currency(__data.costs.property))
    $sprite/subViewport/name.set_text(tr(__data.name))

  elif __data.type == constant_utils.CASE_TYPE.WONDER:
    var side_index = int(get_index() * 4.0 / NUMBER_OF_CASES)

    __wonder_data = _pick_wonder_from_side(side_index)

    $sprite/subViewport/price.set_text(number_utils.format_currency(__data.costs.property))
    $sprite/subViewport/name.set_text(tr(__wonder_data.name))

  else:
    $sprite/subViewport/price.queue_free()
    $sprite/subViewport/name.set_text(tr(__data.name))

func get_case_data():
  return {
    data = __data,
    wonder = __wonder_data,
    game = __game_data
  }

func _pick_wonder_from_side(side_index):
  var rng = RandomNumberGenerator.new()
  var filtered_wonders = []

  rng.randomize()

  for wonder_data in static_data.get_data().wonders:
    if wonder_data.side == side_index:
      filtered_wonders.push_back(wonder_data)

  return filtered_wonders[rng.randi_range(0, filtered_wonders.size() - 1)]

func set_case_data(data):
  __data = data
