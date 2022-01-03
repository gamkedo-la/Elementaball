extends Button

func _on_RestartButton_pressed():
	AudioQueen.emit_signal("stopSound", "Gameplay Music")
	AudioQueen.emit_signal("playSound", "Menu Music")
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
