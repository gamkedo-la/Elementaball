extends PopupPanel

export var closeButton : NodePath


func _on_SelectionMenuPopup_focus_entered():
	get_node(closeButton).grab_focus()
