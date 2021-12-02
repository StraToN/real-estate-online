extends Node3D

const NUMBER_OF_CASES = 36
const BOARD_ANGLE = 360.0

const constant_utils = preload('res://script/util/constants.gd')
const number_utils = preload('res://script/util/number.gd')

var static_data = load('res://data/classic.gd').get_data()

var __data
var __wonder_data
var __game_data = {
  owner = constant_utils.BANK_ID,
  houses = 0,
  number_of_owners = 0,
  olympic_case = null,
  festival = false
}

signal case_selected(case_node)

func _ready():
  rotate_y(deg2rad((-BOARD_ANGLE / NUMBER_OF_CASES) * get_index() + (BOARD_ANGLE / (NUMBER_OF_CASES * 2))))

  $sprite/subViewport/price.set('theme_override_colors/font_shadow_color', __data.color.shadow)
  $sprite/subViewport/price.visible = false
  $sprite/subViewport/name.set('theme_override_colors/font_shadow_color', __data.color.shadow)

  if __data.type == constant_utils.CASE_TYPE.PROPERTY:
    var uniq_material = $ownership.get_active_material(0).duplicate(true)
    var uniq_2_material = $ownership.get_active_material(1).duplicate(true)

    $sprite/subViewport/price.set_text(number_utils.format_currency(__data.costs.property))
    $sprite/subViewport/name.set_text(tr(__data.name))

    $ownership.set_surface_override_material(0, uniq_material)
    $ownership.set_surface_override_material(1, uniq_2_material)

  elif __data.type == constant_utils.CASE_TYPE.WONDER:
    var side_index = int(get_index() * 4.0 / NUMBER_OF_CASES)
    var uniq_material = $ownership.get_active_material(0).duplicate(true)
    var uniq_2_material = $ownership.get_active_material(1).duplicate(true)

    __wonder_data = _pick_wonder_from_side(side_index)

    $sprite/subViewport/price.set_text(number_utils.format_currency(__data.costs.property))
    $sprite/subViewport/name.set_text(tr(__wonder_data.name))

    $ownership.set_surface_override_material(0, uniq_material)
    $ownership.set_surface_override_material(1, uniq_2_material)

  else:
    $ownership.queue_free()
    $sprite/subViewport/price.queue_free()
    $sprite/subViewport/name.set_text(tr(__data.name))

func is_player_own(player_index):
  return __game_data.owner == constant_utils.BANK_ID or __game_data.owner == player_index

func set_input_event_collision(player_index, case_type, value):
  # TODO
  # Add visual feedback for the player to know on which case he/she can click
  if value:
    var owner = get_case_owner()
    var olympic_case = get_olympic_case()

    # Event is either Olympics or a festival
    if case_type == constant_utils.CASE_TYPE.OLYMPICS:
      $selectable.visible = true

      if is_player_own(player_index) and __data.type == constant_utils.CASE_TYPE.PROPERTY:
        $sprite/clickable.connect('input_event', _input_event_collision)

    else:
      if is_player_own(player_index) and \
        (__data.type == constant_utils.CASE_TYPE.WONDER or \
        __data.type == constant_utils.CASE_TYPE.PROPERTY or \
        __data.type == constant_utils.CASE_TYPE.BEGIN or \
        __data.type == constant_utils.CASE_TYPE.OLYMPICS or \
        __data.type == constant_utils.CASE_TYPE.PRISON or \
        __data.type == constant_utils.CASE_TYPE.FESTIVAL or \
        __data.type == constant_utils.CASE_TYPE.WHEEL):
        $sprite/clickable.connect('input_event', _input_event_collision)
        $selectable.visible = true

  elif $sprite/clickable.is_connected('input_event', _input_event_collision):
    $sprite/clickable.disconnect('input_event', _input_event_collision)

  if not value:
    $selectable.visible = false

func set_festival(value):
  # TODO
  # Update visual when a festival is organized
  __game_data.festival = value

func _input_event_collision(camera, event, position, normal, shape_index):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
    emit_signal('case_selected', self)

func get_id():
  return __data.id

func get_type():
  return __data.type

func get_olympic_case():
  return __game_data.olympic_case

func get_rent_bonus():
  var rent_ratio = 1.0

  if __data.type == constant_utils.CASE_TYPE.OLYMPICS or __data.type == constant_utils.CASE_TYPE.FESTIVAL:
    rent_ratio += __data.rent_ratio * (__game_data.number_of_owners + 1)

  return rent_ratio

func get_case_owner():
  return __game_data.owner

func organize_event(player_index, case_node):
  __game_data.olympic_case = case_node

  if __data.type == constant_utils.CASE_TYPE.OLYMPICS:
    # Set the olympic animation to the right case
    _inc_number_of_owner(player_index)

func _inc_number_of_owner(player_index):
  if __game_data.owner != player_index:
    __game_data.number_of_owners += 1

  __game_data.owner = player_index

func buy_property(player_color, player_index, number_of_houses = 0):
  _inc_number_of_owner(player_index)

  match(__data.type):
    constant_utils.CASE_TYPE.OLYMPICS:
      # Nothing to do
      logger.warning('This should not have been called what so ever')

    constant_utils.CASE_TYPE.PROPERTY:
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

      logger.debug('Count: %s', $ownership.get_surface_override_material_count())
      $ownership.get_surface_override_material(0).albedo_color = player_color.lightened(0.95)
      $ownership.get_surface_override_material(1).albedo_color = player_color
      $ownership/animation.play('setup')

    constant_utils.CASE_TYPE.WONDER:
      logger.debug('Count: %s', $ownership.get_surface_override_material_count())

      $ownership.get_surface_override_material(0).albedo_color = player_color.lightened(0.95)
      $ownership.get_surface_override_material(1).albedo_color = player_color
      $ownership/animation.play('setup')

func get_buy_price(buyer_id):
  if __data.type == constant_utils.CASE_TYPE.PROPERTY:
    if buyer_id == __game_data.owner or __game_data.owner == constant_utils.BANK_ID:
      return __data.costs.property

    return (__data.costs.property + __data.costs.house * __game_data.houses) * (__game_data.number_of_owners + 2)

  elif __data.type == constant_utils.CASE_TYPE.WONDER:
    return __data.costs.property

  return __data.costs.flight

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

  return (property_costs + houses_costs) * (__game_data.number_of_owners + 2)

func compute_buy_cost(player_index, number_of_houses):
  return get_buy_price(player_index) + __data.costs.house * (number_of_houses - __game_data.houses)

func compute_rent(number_of_houses):
  var olympic_case = get_olympic_case()
  var festival_case_data = get_festival_case_data()
  var rent_bonus = olympic_case.get_rent_bonus() if olympic_case != null else 1.0
  var festival_bonus = festival_case_data.rent_ratio if __game_data.festival else 0.0

  # TODO
  # - Check if the player owns all the cases of the same property
  # - Check if the player owns the wonder
  return __data.rent[number_of_houses] * (rent_bonus + festival_bonus)

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

  for wonder_data in static_data.wonders:
    if wonder_data.side == side_index:
      filtered_wonders.push_back(wonder_data)

  return filtered_wonders[rng.randi_range(0, filtered_wonders.size() - 1)]

func set_case_data(data):
  __data = data

func get_case_data_with_wonder():
  for case_data in static_data.cases:
    if case_data.id == __wonder_data.case_id:
      return case_data

  logger.warning('Case not found: %s', __wonder_data)

func get_festival_case_data():
  for case_data in static_data.cases:
    if case_data.type == constant_utils.CASE_TYPE.FESTIVAL:
      return case_data
