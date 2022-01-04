extends PopupPanel

export var restartButton : NodePath


func _ready():
	# warning-ignore:return_value_discarded
	SceneController.connect("allKO",self,"_on_Timer_gameOver")

func _on_Timer_gameOver(_winOrLose):
	AudioQueen.play_sound("Long Whistle")
	get_tree().paused = true
	self.show()
	get_node(restartButton).grab_focus()
