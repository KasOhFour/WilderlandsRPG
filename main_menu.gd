class_name MainMenu extends NinePatchRect

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


func _tab_activated(activated_tab: MainMenuTab, deactivated_tab: MainMenuTab) -> void:
	var activated_menu: Control = tab_to_menu_map[activated_tab]
	var deactivated_menu: Control = tab_to_menu_map[deactivated_tab]
	if activated_menu:
		activated_menu.visible = true
	if deactivated_menu:
		deactivated_menu.visible = false
