extends Label

func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("allKO",self,"all_KO")

func _on_Timer_gameOver(winOrLose):
	if winOrLose == "win":
		self.text = "You won!"
		SceneController.emit_signal("winner", "Blue")
	if winOrLose == "lose":
		self.text = "You lost!"
	if winOrLose == "draw":
		self.text = "It's a draw!"

func all_KO(winningTeam):
	if winningTeam == "blue":
		self.text = "You won!"
		SceneController.emit_signal("winner", "Blue")
	else:
		self.text = "You lost!"
