extends Node3D

const DELTA_ACC_INTERVAL = 0.334
const constant_utils = preload('res://script/util/constants.gd')

@export var board_node_path : NodePath

@onready var board_node = get_node(board_node_path)

var __queued_events = []
var __delta_acc = 0.0
var __running_animation = false
var __callback = null
var __lifetime = 0.0
var __waiting_for_lifetime = false

signal animation_played()

func _ready():
  __lifetime = get_node('bank/particle').lifetime
  board_node.connect('currency_moving', _currency_moving)

  set_process(false)

func _currency_moving(from, to, amount):
  __queued_events.push_back({
    from = from,
    to = to,
    amount = amount
  })
  set_process(true)

func _process(delta):
  if __running_animation:
    __delta_acc += delta

    if __delta_acc > DELTA_ACC_INTERVAL:
      __delta_acc -= DELTA_ACC_INTERVAL

      if not is_particle_emitting():
        if not __waiting_for_lifetime:
          __waiting_for_lifetime = true
          __delta_acc -= __lifetime

        else:
          __running_animation = false
          __waiting_for_lifetime = false

          _call_next()
          set_process(__queued_events.size() > 0)

  else:
    _run_animation()

func _call_next():
  if __queued_events.size() < 1 and __callback != null:
    __callback.call()
    __callback = null

func _reset_nodes():
  get_node('bank/attractor').visible = false
  get_node('bank/particle').emitting = false

  get_node('0/attractor').visible = false
  get_node('0/particle').emitting = false

  get_node('1/attractor').visible = false
  get_node('1/particle').emitting = false

  get_node('2/attractor').visible = false
  get_node('2/particle').emitting = false

  get_node('3/attractor').visible = false
  get_node('3/particle').emitting = false

func is_particle_emitting():
  return get_node('bank/particle').emitting or \
         get_node('0/particle').emitting or \
         get_node('1/particle').emitting or \
         get_node('2/particle').emitting or \
         get_node('3/particle').emitting

func _run_animation():
  if __running_animation:
    return

  __delta_acc = 0.0

  if __queued_events.size() < 1:
    _call_next()
    return

  __running_animation = true

  var event_data = __queued_events[0]
  var from_node = get_node('bank') if constant_utils.BANK_ID == event_data.from else get_node(str(event_data.from))
  var to_node = get_node('bank') if constant_utils.BANK_ID == event_data.to else get_node(str(event_data.to))

  _reset_nodes()
  from_node.get_node('attractor').visible = false
  to_node.get_node('attractor').visible = true

  from_node.get_node('particle').amount = max(5, event_data.amount / 1000)
  from_node.get_node('particle').restart()
  from_node.get_node('particle').emitting = true

  __queued_events.pop_front()

func set_callback(callback):
  if __callback != null:
    logger.warning('Overwritting a callback')

  __callback = callback
  _call_next()
