class_name MainMenuTab
extends NinePatchRect

signal activated(tab: MainMenuTab)

const ACTIVE_TEXTURE := preload('res://assets/ui/tab_active.png')
const INACTIVE_TEXTURE := preload('res://assets/ui/tab_inactive.png')
const ACTIVE_ITEM_Y_OFFSET := -4.0
const INACTIVE_ITEM_Y_OFFSET := 0.0
const HIGHLIGHT_ALPHA := 1.00
const NORMAL_ALPHA := 0.52
const LOWLIGHT_ALPHA := 0.45
const HOVERED_SCALE := 1.05
const NORMAL_SCALE := 1.0
const LERP_SPEED := 30.0

@export var is_active := _is_active:
	set(value):
		if value != _is_active:
			_is_active = value
			if _is_active:
				activated.emit(self)
		texture = ACTIVE_TEXTURE if _is_active else INACTIVE_TEXTURE
		var item_texture := active_item_texture if _is_active else inactive_item_texture
		for item: TextureRect in items:
			item.texture = item_texture

		var item_margins := active_item_margins if _is_active else inactive_item_margins
		for margin: MarginContainer in margins:
			for side: String in ['left', 'top', 'right', 'bottom']:
				margin.add_theme_constant_override('margin_%s' % side, item_margins)
	get:
		return _is_active
@export var active_item_texture: Texture2D
@export var inactive_item_texture: Texture2D
@export var active_item_margins: int
@export var inactive_item_margins: int

var is_hovered := false
var item_y_offset := INACTIVE_ITEM_Y_OFFSET
var item_shadow_y := 0.0
var item_view_y := 0.0
var item_scale := _item_scale:
	set(value):
		_item_scale = value
		for margin: MarginContainer in margins:
			margin.scale = Vector2(_item_scale, _item_scale)
	get:
		return _item_scale
var _item_scale := 1.0
var _is_active := false

@onready var items := [
	$ItemShadow/Margin/Item,
	$ItemView/Margin/Item,
]
@onready var margins := [
	$ItemShadow/Margin,
	$ItemView/Margin,
]


func _ready() -> void:
	is_active = _is_active
	item_shadow_y = $ItemShadow.position.y
	item_view_y = $ItemView.position.y
	item_scale = $ItemView/Margin.scale.x


func _process(delta: float) -> void:
	var alpha_to := NORMAL_ALPHA
	var scale_to := NORMAL_SCALE
	var item_shadow_y_to := item_shadow_y + INACTIVE_ITEM_Y_OFFSET
	var item_view_y_to := item_view_y + INACTIVE_ITEM_Y_OFFSET

	if is_hovered and not is_active:
		alpha_to = HIGHLIGHT_ALPHA
		scale_to = HOVERED_SCALE
	self_modulate.a = lerp(self_modulate.a, alpha_to, LERP_SPEED * delta)
	item_scale = lerp(item_scale, scale_to, LERP_SPEED * delta)

	if is_active:
		$Ellipses.visible = true
		item_shadow_y_to = item_shadow_y + ACTIVE_ITEM_Y_OFFSET
		item_view_y_to = item_view_y + ACTIVE_ITEM_Y_OFFSET
	else:
		$Ellipses.visible = false
	$ItemShadow.position.y = lerp($ItemShadow.position.y, item_shadow_y_to, LERP_SPEED * delta)
	$ItemView.position.y = lerp($ItemView.position.y, item_view_y_to, LERP_SPEED * delta)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not is_active:
				is_active = true


func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false
