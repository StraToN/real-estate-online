extends Node3D

const constant_utils = preload('res://script/util/constants.gd')
const number_utils = preload('res://script/util/number.gd')
const static_data = preload('res://data/classic.gd')

const CASE_SCENE = preload('res://scene/classic/case.tscn')
const NUMBER_OF_CASES = 36

const MINIMUM_NUMBER_OF_PLAYERS = 2
const MAXIMUM_NUMBER_OF_PLAYERS = 4

var __number_of_players = 4
var __player_informations = [{
  name = 'Player 1',
  human = true,
  local = true,
  currency = 200000
}, {
  name = 'Player 2',
  human = true,
  local = true,
  currency = 200000
}, {
  name = 'Player 3',
  human = true,
  local = true,
  currency = 200000
}, {
  name = 'Player 4',
  human = true,
  local = true,
  currency = 200000
}]

var STATE_MACHINE = {
  PLAYER_TURN = ['PLAYER_TURN', 'PLAYER_WON'],
  PLAYER_WON = ['PLAYER_WON']
}

# 1. Definir l'ordre des joueurs
# 2. Laisser jouer un joueur et ainsi de suite
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

  _setup_board()
  _player_end_of_turn(3)

func _setup_board():
  for index in range(NUMBER_OF_CASES):
    var case_instance = CASE_SCENE.instantiate()

    case_instance.set_name(str(index))
    case_instance.set_case_data(static_data.get_data().cases[index])
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
      button_node.visible = case_data.game.houses < index

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
  var player_node = $players.get_node(str(player_index))

  player_node.update_currency(-static_data.get_data().world_tour_salary)

func _player_play_case(player_index, case, callback):
  var case_node = $cities.get_node(str(case % 36))
  var case_data = case_node.get_case_data()
  var case_name = tr(case_data.data.name)

  if case_data.data.type == constant_utils.CASE_TYPE.PROPERTY:
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
      # Open bankruptcy panel
      pass

    else:
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

  else:
    # TODO
    logger.debug('Not yet implemented')
    callback.call()

func _update_property_costs(pressed_button, player_currency):
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)

  var cost_value = pressed_button.get_meta('costs')
  var rent_value = pressed_button.get_meta('rent')
  var buy_back = pressed_button.get_meta('buy_back')

  $canvas/property/center/panel/container/costs.set_text('Nouveau loyer: %s' % [number_utils.format_currency(rent_value)])
  $canvas/property/center/panel/container/actions/buy.set_text('Acheter pour %s' % [number_utils.format_currency(cost_value)])
  $canvas/property/center/panel/container/buyback.set_text('Pourra être racheté pour %s' % [number_utils.format_currency(buy_back)])
  $canvas/property/center/panel/container/actions/buy.set_disabled(player_currency < cost_value)

func _buy_property(player_index, case_node, popup_to_close, callback = null):
  var pressed_button = $'canvas/property/center/panel/container/options/0'.button_group.get_pressed_button()
  var number_of_houses = pressed_button.get_meta('houses')
  var cost_value = pressed_button.get_meta('costs')
  var player_node = $players.get_node(str(player_index))

  player_node.update_currency(cost_value)
  case_node.buy_property(player_node.get_player_color(), player_index, number_of_houses)
  _close_popup(popup_to_close, callback)

func _pay_rent(player_index, case_node, popup_to_close, callback = null):
  var rent_costs = case_node.get_rent(player_index)
  var player_node = $players.get_node(str(player_index))

  player_node.update_currency(rent_costs)
  _close_popup(popup_to_close, callback)

func _close_popup(popup_to_close, callback = null):
  soundfx_manager.play_sound(soundfx_manager.FX.UI_CLICK)
  popup_to_close.get_node('animation').play_backwards('open')

  if callback != null:
    callback.call()

func _player_end_of_turn(player_index):
  var next_player_index = (player_index + 1) % __player_informations.size()

  $players.get_node(str(next_player_index)).begin_turn()

func _player_bankrupt(player_index):
  pass

func _player_won(player_index):
  pass
