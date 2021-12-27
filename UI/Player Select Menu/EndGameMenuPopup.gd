extends PopupPanel

export var restartButton : NodePath


func _ready():
	# warning-ignore:return_value_discarded
	SceneController.connect("allKO",self,"_on_Timer_gameOver")
	get_node(restartButton).grab_focus()

func _on_Timer_gameOver(_winOrLose):
	get_tree().paused = true
	self.show()
