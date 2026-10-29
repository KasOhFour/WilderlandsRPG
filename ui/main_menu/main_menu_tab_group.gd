class_name MainMenuTabGroup extends HBoxContainer

signal tab_activated(
	activated_tab: MainMenuTab,
	deactivated_tab: MainMenuTab
)

var activated_tab: MainMenuTab


func _ready() -> void:
	for child in get_children():
		if child is MainMenuTab:
			var tab: MainMenuTab = child
			if not activated_tab:
				activated_tab = tab
				activated_tab.is_active = true
			tab.activated.connect(_on_tab_activated)


func _on_tab_activated(tab: MainMenuTab) -> void:
	var deactivated_tab := activated_tab
	deactivated_tab.is_active = false
	activated_tab = tab
	activated_tab.is_active = true
	tab_activated.emit(activated_tab, deactivated_tab)
