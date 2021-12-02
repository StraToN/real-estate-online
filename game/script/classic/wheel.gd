extends Control

enum SPINNING_WHEEL_STATE {
  WAITING_FOR_PLAYER,
  PLAYER_SPINNING,
  WAITING_FOR_SPINNING,
  SPINNING_DONE
}

var __current_state = SPINNING_WHEEL_STATE.WAITING_FOR_PLAYER
var __angular_velocity = 0.0

func _ready():
  set_process_input(true)

func _input(event):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
    match __current_state:
      SPINNING_WHEEL_STATE.WAITING_FOR_PLAYER:
        if event.pressed:
          __current_state = SPINNING_WHEEL_STATE.PLAYER_SPINNING

      SPINNING_WHEEL_STATE.PLAYER_SPINNING:
        if not event.pressed:
          __current_state = SPINNING_WHEEL_STATE.WAITING_FOR_SPINNING
          __angular_velocity = max(__angular_velocity, randf_range(0.25, 0.8))

  elif event is InputEventMouseMotion and __current_state == SPINNING_WHEEL_STATE.PLAYER_SPINNING:
    var relative_rotation = event.relative.x / -500.0 if event.position.y >= (get_viewport().get_size().y / 2.0) else event.relative.x / 500.0

    if event.position.x >= (get_viewport().get_size().x / 2.0):
      relative_rotation += event.relative.y / 500.0

    else:
      relative_rotation += event.relative.y / -500.0

    __angular_velocity = relative_rotation
    $circles.rotate(relative_rotation)

func _physics_process(delta):
  if __current_state == SPINNING_WHEEL_STATE.WAITING_FOR_SPINNING:
    $circles.rotate(__angular_velocity)
    __angular_velocity -= __angular_velocity * delta

    if __angular_velocity < 0.000000001:
      __current_state = SPINNING_WHEEL_STATE.SPINNING_DONE
