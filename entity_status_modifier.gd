@tool
# entity_status_modifier.gd
class_name EntityStatusModifier
extends Resource

const DEFAULT_NAME := &''
const DEFAULT_MODE := EntityStatusModifier.Mode.UNDEFINED
const DEFAULT_VALUE := 0.00

enum Mode {
	UNDEFINED,
	ABSOLUTE,
	ADDITIVE,
	PERCENTAGE,
	MULTIPLIER,
}

@export var name: StringName
@export var mode: EntityStatusModifier.Mode
@export var value: float


func _init(
		_name := DEFAULT_NAME,
		_mode := DEFAULT_MODE,
		_value := DEFAULT_VALUE,
) -> void:
	name = _name
	mode = _mode
	value = _value
