extends Control

var CanPause = false

func _ready():
	get_node("PauseContainer/Resume").grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("pause") && CanPause:
		get_tree().paused = !get_tree().paused
		visible = !visible


func _on_PlayerSelectMenu_matchStarted():
	CanPause = true


func _on_Resume_pressed():
	get_tree().paused = false
	visible = false


func _on_Quit_pressed():
	get_tree().quit()
