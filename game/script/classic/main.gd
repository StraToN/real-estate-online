extends Node3D

const MINIMUM_NUMBER_OF_PLAYERS = 2
const MAXIMUM_NUMBER_OF_PLAYERS = 4

var __number_of_players = 4
var __player_informations = [{
  name = 'Player 1',
  human = true,
  local = true
}, {
  name = 'Player 2',
  human = true,
  local = true
}, {
  name = 'Player 3',
  human = true,
  local = true
}, {
  name = 'Player 4',
  human = true,
  local = true
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
    $players.get_node(str(index)).set_player_data(player_data)

    $players.get_node(str(index)).connect('player_end_of_turn', _player_end_of_turn)
    $players.get_node(str(index)).connect('player_bankrupt', _player_bankrupt)
    $players.get_node(str(index)).connect('player_won', _player_won)

    index += 1

  _player_end_of_turn(3)

func _player_end_of_turn(player_index):
  var next_player_index = (player_index + 1) % __player_informations.size()

  $players.get_node(str(next_player_index)).begin_turn()

func _player_bankrupt(player_index):
  pass

func _player_won(player_index):
  pass
