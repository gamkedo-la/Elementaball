extends Popup



func _on_Popup_about_to_show():
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	


func _on_Popup_popup_hide():
	pause_mode = Node.PAUSE_MODE_INHERIT
	get_tree().paused = false
