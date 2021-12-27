extends Label

var blueScore = 0
var redScore = 0
export var enemyGoal : NodePath

func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("goalScored", self, "score_goal")
	
func score_goal(goal):
	if goal == get_node(enemyGoal):
		redScore += 1
	else:
		blueScore += 1
		
	self.text = "Final Score: Blue: " + str(blueScore) + " Red: " + str(redScore)
