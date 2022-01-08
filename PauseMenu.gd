extends Control

var CanPause = false

func _process(_delta):
	if Input.is_action_just_pressed("pause") && CanPause:
		get_tree().paused = !get_tree().paused
		visible = !visible
		get_node("PauseContainer/Resume").grab_focus()


func _on_PlayerSelectMenu_matchStarted():
	CanPause = true


func _on_Resume_pressed():
	get_tree().paused = false
	visible = false


func _on_Quit_pressed():
	AudioQueen.emit_signal("stopSound", "Gameplay Music")
	AudioQueen.emit_signal("playSound", "Menu Music")
	get_tree().reload_current_scene()


func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
