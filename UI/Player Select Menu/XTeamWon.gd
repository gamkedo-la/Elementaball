extends Label


func _on_Timer_gameOver(winOrLose):
	if winOrLose == "win":
		self.text = "You won!"
	if winOrLose == "lose":
		self.text = "You lost!"
	if winOrLose == "draw":
		self.text = "It's a draw!"
