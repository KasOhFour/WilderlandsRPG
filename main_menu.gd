class_name MainMenu extends NinePatchRect

@onready var dimmer := $ColorRect
@onready var player_sheet := $PlayerSheet
@onready var main_menu_tab_group := $MainMenuTabGroup

@onready var tab_to_menu_map: Dictionary = {
	main_menu_tab_group.get_child(0): player_sheet,
	main_menu_tab_group.get_child(1): null,
	main_menu_tab_group.get_child(2): null,
	main_menu_tab_group.get_child(3): null,
	main_menu_tab_group.get_child(4): null,
	main_menu_tab_group.get_child(5): null,
}


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('toggle_menu'):
		dimmer.visible = not visible
		visible = not visible
		return
	if event is InputEventMouseButton and event.pressed:
		var gcim := GlobalCursorItemManager
		var rect = get_global_rect()
		if not rect.has_point(event.position) and not gcim.item_stack.is_empty():
			var scene_root := get_tree().current_scene
			var player_body_2d: PlayerBody2D = get_tree().get_first_node_in_group('player')
			var item_position := (player_body_2d.global_position.y - player_body_2d.magnetic_field.global_position.y) * randf_range(0.90, 1.10)
			var item_stack_2d := ItemStack2D.instance(
				gcim.item_stack.copy(),
				Vector2(0.00, item_position),
				Vector2(randf_range(120.00, 125.00), 0.00),
				player_body_2d.magnetic_field.global_position,
				1.50,
				randf_range(0.60, 0.72),
			)
			gcim.item_stack.clear()
			scene_root.add_child(item_stack_2d)
			visible = false


func _tab_activated(activated_tab: MainMenuTab, deactivated_tab: MainMenuTab) -> void:
	var activated_menu: Control = tab_to_menu_map[activated_tab]
	var deactivated_menu: Control = tab_to_menu_map[deactivated_tab]
	if activated_menu:
		activated_menu.visible = true
	if deactivated_menu:
		deactivated_menu.visible = false
