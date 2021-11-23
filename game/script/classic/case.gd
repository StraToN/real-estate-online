extends Node3D

const NUMBER_OF_CASES = 36
const BOARD_ANGLE = 360.0

const constant_utils = preload('res://script/util/constants.gd')
const number_utils = preload('res://script/util/number.gd')
const static_data = preload('res://data/classic.gd')

var __data
var __wonder_data

var __game_data = {
  owner = constant_utils.BANK_ID,
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
    var uniq_material = $ownership.get_active_material(0).duplicate(true)

    $sprite/subViewport/price.set_text(number_utils.format_currency(__data.costs.property))
    $sprite/subViewport/name.set_text(tr(__data.name))
    $ownership.set_surface_override_material(0, uniq_material)

  elif __data.type == constant_utils.CASE_TYPE.WONDER:
    var side_index = int(get_index() * 4.0 / NUMBER_OF_CASES)
    var uniq_material = $ownership.get_active_material(0).duplicate(true)

    __wonder_data = _pick_wonder_from_side(side_index)

    $sprite/subViewport/price.set_text(number_utils.format_currency(__data.costs.property))
    $sprite/subViewport/name.set_text(tr(__wonder_data.name))
    $ownership.set_surface_override_material(0, uniq_material)

  else:
    $ownership.queue_free()
    $sprite/subViewport/price.queue_free()
    $sprite/subViewport/name.set_text(tr(__data.name))

func get_id():
  return __data.id

func get_type():
  return __data.type

func get_case_owner():
  return __game_data.owner

func buy_property(player_color, player_index, number_of_houses = 0):
  if __game_data.owner != player_index:
    __game_data.number_of_owners += 1

  __game_data.owner = player_index

  if __data.type == constant_utils.CASE_TYPE.PROPERTY:
    __game_data.houses = number_of_houses

    if number_of_houses < 5:
      for index in range(1, 6):
        $ownership.get_node(str(index)).visible = index <= number_of_houses

    else:
      $'ownership/1'.visible = false
      $'ownership/2'.visible = false
      $'ownership/3'.visible = false
      $'ownership/4'.visible = false
      $'ownership/5'.visible = true

  $ownership.get_surface_override_material(0).albedo_color = player_color
  $ownership/animation.play('setup')

func get_buy_price(buyer_id):
  if __data.type == constant_utils.CASE_TYPE.PROPERTY:
    if buyer_id == __game_data.owner or __game_data.owner == constant_utils.BANK_ID:
      return __data.costs.property

    return (__data.costs.property + __data.costs.house * __game_data.houses) * (__game_data.number_of_owners + 2)

  else:
    return __data.costs.property

func is_option_visible(player_index, nb_of_houses):
  if __data.type == constant_utils.CASE_TYPE.PROPERTY:
    if player_index != __game_data.owner and __game_data.owner != constant_utils.BANK_ID:
      return nb_of_houses >= __game_data.houses

    return nb_of_houses > __game_data.houses

  else:
    return get_case_owner() == constant_utils.BANK_ID

func compute_buy_back(buyer_id, number_of_houses):
  var property_costs = get_buy_price(buyer_id)
  var houses_costs = (number_of_houses - __game_data.houses) * __data.costs.house
  var computed_number_of_owner = __game_data.number_of_owners + 2

  if buyer_id != __game_data.owner and __game_data.owner != constant_utils.BANK_ID:
    computed_number_of_owner += 1

  return (property_costs + houses_costs) * computed_number_of_owner

func compute_buy_cost(player_index, number_of_houses):
  return get_buy_price(player_index) + __data.costs.house * (number_of_houses - __game_data.houses)

func compute_rent(number_of_houses):
  # TODO
  # - Add the wonders to the equation
  # - Check if the player owns all the cases of the same property
  return __data.rent[number_of_houses]

func get_rent(player_index):
  if player_index == __game_data.owner or __game_data.owner == constant_utils.BANK_ID:
    return 0

  return compute_rent(__game_data.houses)

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

func get_case_with_wonder():
  for case_data in static_data.get_data().cases:
    if case_data.id == __wonder_data.case_id:
      return case_data

  logger.warning('Case not found: %s', __wonder_data)
