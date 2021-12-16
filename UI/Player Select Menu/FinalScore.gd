extends Label

var blueScore = 0
var redScore = 0

func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("goalScored", self, "score_goal")
	
func score_goal(kicker):
	if kicker in get_tree().get_nodes_in_group("player_team"):
		blueScore += 1
	else:
		redScore += 1
		
	self.text = "Final Score: Blue: " + str(blueScore) + " Red: " + str(redScore)
