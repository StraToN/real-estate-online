extends Node3D

const ANIMATION_DURATION = 0.334

var __catch_event = false

func _ready():
  set_process_unhandled_input(true)

func _unhandled_input(event):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
    __catch_event = event.pressed

    # SceneTree.set_input_as_handled()

  elif event is InputEventMouseMotion and __catch_event:
    var relative_rotation = event.relative.x / -500.0 if event.position.y >= (get_viewport().get_size().y / 2.0) else event.relative.x / 500.0

    if event.position.x >= (get_viewport().get_size().x / 2.0):
      relative_rotation += event.relative.y / 500.0

    else:
      relative_rotation += event.relative.y / -500.0

    rotate_y(relative_rotation)

func lock_rotation():
  var tween = create_tween()

  tween.set_parallel(true)
  tween.tween_property(self, 'rotation', Vector3(0.0, 0.0, 0.0), ANIMATION_DURATION).set_trans(Tween.TRANS_SINE)
  set_process_unhandled_input(false)

func unlock_rotation():
  set_process_unhandled_input(true)
