# item_slot.gd
class_name ItemSlot
extends Control
## Pure view for one inventory slot. Translates raw input into intent signals
## and plays the hover animation; it never modifies item stacks.

signal primary_pressed(shift: bool)
signal secondary_pressed(shift: bool)
signal double_pressed()
signal hover_entered()
signal hover_exited()

const HIGHLIGHT_ALPHA := 1.00
const NORMAL_ALPHA := 0.52
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const TWEEN_DURATION := 0.1

var is_highlighted := false:
	set(value):
		if value == is_highlighted:
			return
		is_highlighted = value
		_animate_highlight()
var item_stack: ItemStack:
	set(value):
		_pending_item_stack = value
		if isui:
			isui.item_stack = value
	get:
		return isui.item_stack if isui else _pending_item_stack

var _pending_item_stack: ItemStack
var _tween: Tween

@onready var isui: ItemStackUI = $ItemStackUI
@onready var panel: Panel = $Panel


func _ready() -> void:
	panel.self_modulate.a = HIGHLIGHT_ALPHA if is_highlighted else NORMAL_ALPHA
	if _pending_item_stack:
		isui.item_stack = _pending_item_stack


func _animate_highlight() -> void:
	if not is_node_ready():
		return

	var alpha_to := HIGHLIGHT_ALPHA if is_highlighted else NORMAL_ALPHA
	var scale_to := HOVERED_SCALE if is_highlighted else NORMAL_SCALE

	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	_tween.tween_property(panel, "self_modulate:a", alpha_to, TWEEN_DURATION)
	_tween.tween_property(isui, "item_scale", scale_to, TWEEN_DURATION)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed:
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if event.double_click:
				double_pressed.emit()
			else:
				primary_pressed.emit(event.shift_pressed)
		MOUSE_BUTTON_RIGHT:
			secondary_pressed.emit(event.shift_pressed)


func _on_mouse_entered() -> void:
	is_highlighted = true
	hover_entered.emit()


func _on_mouse_exited() -> void:
	is_highlighted = false
	hover_exited.emit()
