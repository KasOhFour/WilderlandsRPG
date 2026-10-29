@tool
# entity_status.gd
class_name EntityStatus
extends Resource

signal value_changed(delta: float)

enum IntegerRounding {
	UNDEFINED,
	ROUND,
	FLOOR,
	CEIL,
}

const DEFAULT_NAME := &''
const DEFAULT_VALUE := 0.00
const DEFAULT_ROUNDING := IntegerRounding.UNDEFINED

@export var name: StringName
@export var value: float:
	set = _set_value
@export var rounding: IntegerRounding


func _init(
		_name := DEFAULT_NAME,
		_value := DEFAULT_VALUE,
		_rounding := DEFAULT_ROUNDING,
) -> void:
	name = _name
	value = _value
	rounding = _rounding


func _set_value(_value: float) -> void:
	var old_value := value

	match rounding:
		IntegerRounding.ROUND:
			_value = round(_value)
		IntegerRounding.FLOOR:
			_value = floor(_value)
		IntegerRounding.CEIL:
			_value = ceil(_value)

	value = _value
	var delta := value - old_value
	if delta == 0:
		return

	value_changed.emit(delta)
