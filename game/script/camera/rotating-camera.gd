extends Node3D

var __catch_event = false

func _ready():
  set_process_unhandled_input(true)

func _unhandled_input(event):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
    __catch_event = event.pressed

    # SceneTree.set_input_as_handled()

  elif event is InputEventMouseMotion and __catch_event:
    if event.position.y >= (get_viewport().get_size().y / 2.0):
      rotate_y(event.relative.x / -500.0)
    else:
      rotate_y(event.relative.x / 500.0)
