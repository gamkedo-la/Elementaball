extends Label


func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("allKO",self,"all_KO")
	
func all_KO(winningTeam):
	if winningTeam == "blue":
		self.text = "All the red players were knocked out!"
	else:
		self.text = "All the blue players were knocked out!"
