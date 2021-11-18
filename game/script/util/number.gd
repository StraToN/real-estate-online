# To include it
# const number_utils = preload('res://script/util/number.gd')

const ordinary_factor = 10
const range_factor = 1000
const units = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']

static func format_space(number):
  return format_dot(number, ' ')

static func format_dot(number, separator = '.'):
  var str_number = str(int(number))
  var str_number_size = str_number.length()
  var str_amount_of_dots = floor((str_number_size - 1) / 3)

  for index in range(0, str_amount_of_dots):
    var str_index = str_number_size - (index + 1) * 3

    str_number = str_number.insert(str_index, separator)

  return str_number

static func format_currency(number):
  return _format(number, '%.2f %s$')

static func format(number):
  return _format(number, '%.2f %s')

static func format_short(number):
  return _format(number, '%.1f %s')

static func iformat_currency(number):
  return _format(number, '%d %s$')

static func iformat(number):
  return _format(number, '%d %s')

static func iformat_long(number):
  var string = '%d' % [number]
  var length = floor(string.length() / 3.0)

  # Guard clause
  if length < 1:
    return string

  for index in range(0, length):
    string = string.insert(string.length() - (3 * (index + 1) + index), ' ')

  return string

static func _format(number, format_text_custom):
  if number == null:
    number = 0.0

  var unit_index = 0
  var ratio = 1
  var abs_number = abs(number)
  var format_text = '%d %s'

  for index in range(0, units.size()):
    var computed_ratio = pow(range_factor, index)

    if abs_number > computed_ratio:
      ratio = computed_ratio
      unit_index = index

      if index == 1:
        format_text = format_text_custom

    else:
      break

  return format_text % [(number / ratio), units[unit_index]]
