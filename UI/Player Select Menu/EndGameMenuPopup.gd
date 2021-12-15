extends PopupPanel



func _on_Timer_gameOver(winOrLose):
	get_tree().paused = true
	self.show()
