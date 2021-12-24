extends PopupPanel


func _ready():
	# warning-ignore:return_value_discarded
	SceneController.connect("allKO",self,"_on_Timer_gameOver")

func _on_Timer_gameOver(_winOrLose):
	get_tree().paused = true
	self.show()
