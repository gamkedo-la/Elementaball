extends PopupPanel



func _on_Timer_gameOver(_winOrLose):
	get_tree().paused = true
	self.show()
