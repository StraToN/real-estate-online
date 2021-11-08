extends Node3D

const NOT_IMPORTANT_ANGLE = -9999
const EPSILON = 0.01
const DICE_VALUE = [
  Vector3(90, NOT_IMPORTANT_ANGLE, NOT_IMPORTANT_ANGLE), # 1
  Vector3(0, 0, 180), # 2
  Vector3(0, NOT_IMPORTANT_ANGLE, 90), # 3
  Vector3(0, NOT_IMPORTANT_ANGLE, -90), # 4
  Vector3(0, NOT_IMPORTANT_ANGLE, 0), # 5
  Vector3(-90, NOT_IMPORTANT_ANGLE, NOT_IMPORTANT_ANGLE), # 6
]

func _ready():
  set_process(true)

func _process(delta):
  print(get_value())

func get_value():
  var value = 1
  var l_global_rotation = $rigidBody.global_transform.basis.get_euler()

  l_global_rotation.x = int(round(rad2deg(l_global_rotation.x) / 90.0)) * 90
  l_global_rotation.y = int(round(rad2deg(l_global_rotation.y) / 90.0)) * 90
  l_global_rotation.z = int(round(rad2deg(l_global_rotation.z) / 90.0)) * 90

  for computed_angle in DICE_VALUE:
    if (computed_angle.x == NOT_IMPORTANT_ANGLE or \
        abs(computed_angle.x - l_global_rotation.x) < EPSILON) and \
       (computed_angle.y == NOT_IMPORTANT_ANGLE or \
        abs(computed_angle.y - l_global_rotation.y) < EPSILON) and \
       (computed_angle.z == NOT_IMPORTANT_ANGLE or \
        abs(computed_angle.z - l_global_rotation.z) < EPSILON):
      break
    value += 1

  return value
