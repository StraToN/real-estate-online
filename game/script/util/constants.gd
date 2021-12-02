extends Object
# To import this script
# const constant_utils = preload('res://script/util/constants.gd')

const BANK_ID = -1

enum PLAYER_TYPE {
  HUMAN_LOCAL,
  HUMAN_REMOTE,
  COMPUTER_LOCAL,
  COMPUTER_REMOTE
}

enum CASE_TYPE {
  BEGIN,
  PRISON,
  AIRPORT,
  OLYMPICS,

  WONDER,
  PROPERTY,
  TAXES,
  FESTIVAL,
  WHEEL
}

enum CARD_TYPE {
  RANDOM,
  ANARCHY,
  PRISON,
  AIRPORT
}
