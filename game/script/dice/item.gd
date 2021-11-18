extends RigidDynamicBody3D

const DICE_DEFAULT_POSITION_RANGE = 0.3
const PERPANDICULAR_ANGLE = 90
const NOT_IMPORTANT_ANGLE = -9999
const EPSILON = 5.0
const DICE_VALUE = [
  Vector3(90, NOT_IMPORTANT_ANGLE, NOT_IMPORTANT_ANGLE), # 1
  Vector3(0, 0, 180), # 2
  Vector3(0, NOT_IMPORTANT_ANGLE, 90), # 3
  Vector3(0, NOT_IMPORTANT_ANGLE, -90), # 4
  Vector3(0, NOT_IMPORTANT_ANGLE, 0), # 5
  Vector3(-90, NOT_IMPORTANT_ANGLE, NOT_IMPORTANT_ANGLE), # 6
]
const SLEEPING_VECTOR3 = Vector3(EPSILON, EPSILON, EPSILON) * 10.0

func _ready():
  connect('body_entered', _play_sound, [])
  # connect('body_shape_entered', _play_sound, [])
  set_freeze_enabled(false)

  rotate_x(deg2rad(randi() % 180))
  rotate_y(deg2rad(randi() % 180))
  rotate_z(deg2rad(randi() % 180))

func _play_sound(arg0 = null, arg1 = null, arg2 = null, arg3 = null):
  $soundFX.unit_db = lerp(-10.0, -8.0, linear_velocity.normalized().x)
  $soundFX.pitch_scale = lerp(0.95, 1.05, angular_velocity.normalized().x)
  $soundFX.play()

func is_entity_moving():
  return abs(angular_velocity) > SLEEPING_VECTOR3 or \
         abs(linear_velocity) > SLEEPING_VECTOR3

func is_dice_broken():
  return get_value() > 6

func reset_dice():
  rotation = Vector3(deg2rad(randi() % 180), deg2rad(randi() % 180), deg2rad(randi() % 180))
  position = Vector3(randf_range(-DICE_DEFAULT_POSITION_RANGE, DICE_DEFAULT_POSITION_RANGE), 0.5, randf_range(-DICE_DEFAULT_POSITION_RANGE, DICE_DEFAULT_POSITION_RANGE))

func stop_dice():
  sleeping = true

func get_value():
  var value = 1
  var l_global_rotation = global_transform.basis.get_euler()

  l_global_rotation.x = int(round(rad2deg(l_global_rotation.x) / PERPANDICULAR_ANGLE)) * PERPANDICULAR_ANGLE
  l_global_rotation.y = int(round(rad2deg(l_global_rotation.y) / PERPANDICULAR_ANGLE)) * PERPANDICULAR_ANGLE
  l_global_rotation.z = int(round(rad2deg(l_global_rotation.z) / PERPANDICULAR_ANGLE)) * PERPANDICULAR_ANGLE

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
