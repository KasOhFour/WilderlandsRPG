@tool
# entity_status_effect.gd
class_name EntityStatusEffect
extends Resource

const DEFAULT_NAME := &''
const DEFAULT_DELTA := 0.00
const DEFAULT_MODIFIERS: Array[EntityStatusModifier] = []
const DEFAULT_PROC_DELTA := 0.00

@export var name: StringName
@export var delta: float
@export var modifiers: Array[EntityStatusModifier]
@export var proc_delta: float
@export var proc_check: Callable


func _init(
		_name := DEFAULT_NAME,
		_delta := DEFAULT_DELTA,
		_modifiers := DEFAULT_MODIFIERS,
		_proc_delta := DEFAULT_PROC_DELTA,
		_proc_check := func(): return true,
) -> void:
	if not name:
		name = _name
	if not delta:
		delta = _delta
	if not modifiers:
		modifiers = _modifiers
	if not proc_delta:
		proc_delta = _proc_delta
	if not proc_check:
		proc_check = _proc_check
