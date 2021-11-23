extends Node3D

const constant_utils = preload('res://script/util/constants.gd')
const number_utils = preload('res://script/util/number.gd')

const CASE_SCENE = preload('res://scene/classic/case.tscn')

const MINIMUM_NUMBER_OF_PLAYERS = 2
const MAXIMUM_NUMBER_OF_PLAYERS = 4

var static_data = load('res://data/classic.gd').get_data()

var __player_informations = [{
  name = 'Player 1',
  human = true,
  local = true,
  currency = static_data.currency
}, {
  name = 'Player 2',
  human = true,
  local = true,
  currency = static_data.currency
}, {
  name = 'Player 3',
  human = true,
  local = true,
  currency = static_data.currency
}, {
  name = 'Player 4',
  human = true,
  local = true,
  currency = static_data.currency
}]

signal currency_moving(from, to, amount)

var STATE_MACHINE = {
  PLAYER_TURN = ['PLAYER_TURN', 'PLAYER_WON'],
  PLAYER_WON = ['PLAYER_WON']
}

func _ready():
  var index = 0

  for player_data in __player_informations:
    var node_index = str(index)

    $players.get_node(node_index).set_player_data(player_data)

    $players.get_node(node_index).connect('player_end_of_turn', _player_end_of_turn)
    $players.get_node(node_index).connect('player_bankrupt', _player_bankrupt)
    $players.get_node(node_index).connect('player_won', _player_won)

    $players.get_node(node_index).connect('player_play_case', _player_play_case)
    $players.get_node(node_index).connect('player_world_tour_ended', _player_pay_salary)

    index += 1

  connect('currency_moving', _update_players_currency)

  _setup_board()
  _player_end_of_turn(3)

func _update_players_currency(from_player, to_player, amount):
  if from_player != constant_utils.BANK_ID:
    var player_node = str(from_player)

    $players.get_node(player_node).update_currency(amount)

  if to_player != constant_utils.BANK_ID:
    var player_node = str(to_player)

    $players.get_node(player_node).update_currency(-amount)

func _setup_board():
  for index in range(static_data.number_of_cases):
    var case_instance = CASE_SCENE.instantiate()

    case_instance.set_name(str(index))
    case_instance.set_case_data(static_data.cases[index])
    $cities.add_child(case_instance)

func _initialize_property_data(case_node, case_data, player_index):
  for index in range(0, 6):
    var button_node = $'canvas/property/center/panel/container/options'.get_node(str(index))
    var costs = case_node.compute_buy_cost(player_index, index)

    button_node.set_meta('houses', index)
    button_node.set_meta('costs', costs)
    button_node.set_meta('rent', case_node.compute_rent(index))
    button_node.set_meta('buy_back', case_node.compute_buy_back(player_index, index))
    button_node.set_pressed(false)

    if index > 0:
      button_node.visible = case_node.is_option_visible(player_index, index)

      if index >= 5:
        button_node.set_text('1 hôtel\n%s' % [
          number_utils.format_currency(costs)
        ])

      else:
        button_node.set_text('%s maison(s)\n%s' % [
          index, number_utils.format_currency(costs)
        ])

    else:
      button_node.visible = case_data.game.houses == 0
      button_node.set_text('Terrain seul\n%s' % [
        number_utils.format_currency(costs)
      ])

func _player_pay_salary(player_index):
  var currency = static_data.world_tour_salary

  emit_signal('currency_moving', constant_utils.BANK_ID, player_index, currency)

func _play_property(player_index, case_node, case_data, case_name, callback):
  # Note:
  # First we need to disconnect everysingle signal since
  # The popup is never deleted/created w are re-using the same scene
  if $canvas/property/center/panel/container/actions/buy.is_connected('pressed', _buy_property):
    $canvas/property/center/panel/container/actions/buy.disconnect('pressed', _buy_property)

  if $canvas/property/center/panel/container/actions/close.is_connected('pressed', _close_popup):
    $canvas/property/center/panel/container/actions/close.disconnect('pressed', _close_popup)

  if $canvas/property/center/panel/container/actions/close.is_connected('pressed', _close_popup):
    $canvas/property/center/panel/container/actions/close.disconnect('pressed', _close_popup)

  if $canvas/property/center/panel/marginContainer/close.is_connected('pressed', _close_popup):
    $canvas/property/center/panel/marginContainer/close.disconnect('pressed', _close_popup)

  if $'canvas/property/center/panel/container/options/0'.button_group.is_connected('pressed', _update_property_costs):
    $'canvas/property/center/panel/container/options/0'.button_group.disconnect('pressed', _update_property_costs)

  var player_currency = $players.get_node(str(player_index)).get_currency()
  var player_number_of_turn = $players.get_node(str(player_index)).get_number_of_turn()
  var rental_costs = case_node.get_rent(player_index)

  _initialize_property_data(case_node, case_data, player_index)

  $canvas/property/center/panel/container/actions/buy.connect('pressed', _buy_property, [player_index, case_node, $canvas/property, callback], CONNECT_ONESHOT)
  $canvas/property/center/panel/container/actions/buy.set_disabled(true)
  $canvas/property/center/panel/container/title.set_text(case_name)
  $canvas/property/animation.play('open')

  # Note
  # Player doesn't own the property
  if rental_costs > 0:
    $canvas/property/center/panel/marginContainer/close.visible = false

    $canvas/property/center/panel/container/actions/buy.set_disabled(true)
    $canvas/property/center/panel/container/actions/close.set_text('Payer %s' % [number_utils.format_currency(rental_costs)])
    $canvas/property/center/panel/container/actions/close.connect('pressed', _pay_rent, [player_index, case_node, $canvas/property, callback], CONNECT_ONESHOT)
    $'canvas/property/center/panel/container/options/0'.button_group.connect('pressed', _update_property_costs, [player_currency])

  else:
    $canvas/property/center/panel/container/actions/close.set_text('BUTTON_CLOSE')
    $canvas/property/center/panel/marginContainer/close.visible = true

    $canvas/property/center/panel/container/actions/close.connect('pressed', _close_popup, [$canvas/property, callback], CONNECT_ONESHOT)
    $canvas/property/center/panel/marginContainer/close.connect('pressed', _close_popup, [$canvas/property, callback], CONNECT_ONESHOT)
    $'canvas/property/center/panel/container/options/0'.button_group.connect('pressed', _update_property_costs, [player_currency])

  if rental_costs > player_currency:
    # TODO
    # Bankruptcy not taken into account
    pass

  if player_number_of_turn < 1:
    $'canvas/property/center/panel/container/options/1'.set_disabled(false)
    $'canvas/property/center/panel/container/options/2'.set_disabled(false)
    $'canvas/property/center/panel/container/options/3'.set_disabled(false)
    $'canvas/property/center/panel/container/options/4'.set_disabled(true)
    $'canvas/property/center/panel/container/options/5'.set_disabled(true)

  elif case_data.game.houses < 4:
    $'canvas/property/center/panel/container/options/1'.set_disabled(false)
    $'canvas/property/center/panel/container/options/2'.set_disabled(false)
    $'canvas/property/center/panel/container/options/3'.set_disabled(false)
    $'canvas/property/center/panel/container/options/4'.set_disabled(false)
    $'canvas/property/center/panel/container/options/5'.set_disabled(true)

  elif case_data.game.houses < 5:
    $'canvas/property/center/panel/container/options/1'.set_disabled(false)
    $'canvas/property/center/panel/container/options/2'.set_disabled(false)
    $'canvas/property/center/panel/container/options/3'.set_disabled(false)
    $'canvas/property/center/panel/container/options/4'.set_disabled(false)
    $'canvas/property/center/panel/container/options/5'.set_disabled(false)

  else:
    $'canvas/property/center/panel/container/options/1'.set_disabled(true)
    $'canvas/property/center/panel/container/options/2'.set_disabled(true)
    $'canvas/property/center/panel/container/options/3'.set_disabled(true)
    $'canvas/property/center/panel/container/options/4'.set_disabled(true)
    $'canvas/property/center/panel/container/options/5'.set_disabled(true)

func _play_wonder(player_index, case_node, case_data, case_name, callback):
  # Note:
  # First we need to disconnect everysingle signal since
  # The popup is never deleted/created w are re-using the same scene
  if $canvas/wonder/center/panel/container/actions/buy.is_connected('pressed', _buy_wonder):
    $canvas/wonder/center/panel/container/actions/buy.disconnect('pressed', _buy_wonder)

  if $canvas/wonder/center/panel/container/actions/close.is_connected('pressed', _close_popup):
    $canvas/wonder/center/panel/container/actions/close.disconnect('pressed', _close_popup)

  if $canvas/wonder/center/panel/container/actions/close.is_connected('pressed', _close_popup):
    $canvas/wonder/center/panel/container/actions/close.disconnect('pressed', _close_popup)

  if $canvas/wonder/center/panel/marginContainer/close.is_connected('pressed', _close_popup):
    $canvas/wonder/center/panel/marginContainer/close.disconnect('pressed', _close_popup)

  var player_currency = $players.get_node(str(player_index)).get_currency()

  # Initialize the popup
  var linked_property = case_node.get_case_with_wonder()
  var owned_wonders = get_cases_owned_by_player_and_type(player_index)

  $canvas/wonder/center/panel/container/title.set_text(case_name)
  $canvas/wonder/center/panel/container/richTextLabel.text = 'Si vous possédez également %s, alors le loyer de %s sera doublé' % [
    tr(linked_property.name), tr(linked_property.name)
  ]

  for index in range(0, 4):
    var rent_label = $canvas/wonder/center/panel/container/rent.get_node(str(index))

    rent_label.set_text('%s merveilles - %s$' % [
      index + 1, number_utils.format(case_node.compute_rent(index))
    ])

    if owned_wonders.size() == (index + 1):
      rent_label.set('theme_override_font_sizes/font_size', 18)

    else:
      rent_label.set('theme_override_font_sizes/font_size', 14)

  $canvas/wonder/animation.play('open')

  if case_node.get_case_owner() == constant_utils.BANK_ID:
    var wonder_buy_costs = case_node.get_buy_price(player_index)

    $canvas/wonder/center/panel/container/actions/close.set_text('BUTTON_CLOSE')
    $canvas/wonder/center/panel/marginContainer/close.visible = true

    $canvas/wonder/center/panel/container/actions/buy.connect('pressed', _buy_wonder, [player_index, case_node, $canvas/wonder, callback], CONNECT_ONESHOT)
    $canvas/wonder/center/panel/container/actions/buy.set_disabled(wonder_buy_costs > player_currency)
    $canvas/wonder/center/panel/container/actions/buy.set_text('Acheter pour %s' % [number_utils.format_currency(wonder_buy_costs)])
    $canvas/wonder/center/panel/container/actions/close.connect('pressed', _close_popup, [$canvas/wonder, callback], CONNECT_ONESHOT)
    $canvas/wonder/center/panel/marginContainer/close.connect('pressed', _close_popup, [$canvas/wonder, callback], CONNECT_ONESHOT)

  elif case_node.get_case_owner() != player_index:
    # TODO
    # Bankruptcy not taken into account
    var rental_costs = case_node.get_rent(player_index)

    $canvas/wonder/center/panel/marginContainer/close.visible = false

    $canvas/wonder/center/panel/container/actions/buy.set_disabled(true)
    $canvas/wonder/center/panel/container/actions/close.set_text('Payer %s' % [number_utils.format_currency(rental_costs)])
    $canvas/wonder/center/panel/container/actions/close.connect('pressed', _pay_rent, [player_index, case_node, $canvas/wonder, callback], CONNECT_ONESHOT)

  else:
    # Nothing to do
    callback.call()

func _player_play_case(player_index, case, callback):
  var case_node = $cities.get_node(str(case % 36))
  var case_data = case_node.get_case_data()
  var case_name = tr(case_data.data.name)

  if case_data.data.type == constant_utils.CASE_TYPE.PROPERTY:
    _play_property(player_index, case_node, case_data, case_name, callback)

  elif case_data.data.type == constant_utils.CASE_TYPE.WONDER:
    _play_wonder(player_index, case_node, case_data, case_name, callback)

  else:
    # TODO
    logger.debug('Not yet implemented')
    callback.call()

func _update_property_costs(pressed_button, player_currency):
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  var cost_value = pressed_button.get_meta('costs')
  var rent_value = pressed_button.get_meta('rent')
  var buy_back = pressed_button.get_meta('buy_back')

  # TODO
  # Cannot buy back a property with an hostel
  $canvas/property/center/panel/container/costs.set_text('Nouveau loyer: %s' % [number_utils.format_currency(rent_value)])
  $canvas/property/center/panel/container/actions/buy.set_text('Acheter pour %s' % [number_utils.format_currency(cost_value)])
  $canvas/property/center/panel/container/buyback.set_text('Pourra être racheté pour %s' % [number_utils.format_currency(buy_back)])
  $canvas/property/center/panel/container/actions/buy.set_disabled(player_currency < cost_value)

func _buy_wonder(player_index, case_node, popup_to_close, callback = null):
  var player_node = $players.get_node(str(player_index))
  var buy_property_value = case_node.get_buy_price(player_index)

  emit_signal('currency_moving', player_index, constant_utils.BANK_ID, buy_property_value)
  case_node.buy_property(player_node.get_player_color(), player_index)
  _close_popup(popup_to_close, callback)

func _buy_property(player_index, case_node, popup_to_close, callback = null):
  var pressed_button = $'canvas/property/center/panel/container/options/0'.button_group.get_pressed_button()
  var number_of_houses = pressed_button.get_meta('houses')
  var cost_value = pressed_button.get_meta('costs')
  var player_node = $players.get_node(str(player_index))
  var previous_owner = case_node.get_case_owner()
  var buy_back_value = case_node.get_buy_price(player_index)
  var construction_cost = buy_back_value - cost_value

  if previous_owner != constant_utils.BANK_ID:
    emit_signal('currency_moving', player_index, previous_owner, buy_back_value)
    emit_signal('currency_moving', player_index, constant_utils.BANK_ID, construction_cost)

  else:
    emit_signal('currency_moving', player_index, previous_owner, cost_value)

  case_node.buy_property(player_node.get_player_color(), player_index, number_of_houses)
  _close_popup(popup_to_close, callback)

func _pay_rent(player_index, case_node, popup_to_close, callback = null):
  var rent_costs = case_node.get_rent(player_index)
  var current_owner = case_node.get_case_owner()

  emit_signal('currency_moving', player_index, current_owner, rent_costs)
  _close_popup(popup_to_close, callback)

func _close_popup(popup_to_close, callback = null):
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)
  popup_to_close.get_node('animation').play_backwards('open')

  if callback != null:
    $player/camera/money.set_callback(callback)

func _player_end_of_turn(player_index):
  var next_player_index = (player_index + 1) % __player_informations.size()

  $players.get_node(str(next_player_index)).begin_turn()

func _player_bankrupt(player_index):
  pass

func _player_won(player_index):
  pass

func get_cases_owned_by_player_and_type(player_index, case_type = constant_utils.CASE_TYPE.WONDER):
  var owned_cases = []

  for case_node in $cities.get_children():
    if case_node.get_type() == case_type and case_node.get_case_owner() == player_index:
      owned_cases.push_back(case_node)

  return owned_cases
