extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Node2D.tscn")


func _on_StartButton_focus_entered():
	AudioQueen.play_sound("Menu Up-Down")


func _on_StartButton_focus_exited():
	AudioQueen.play_sound("Menu Up-Down")
