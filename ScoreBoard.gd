extends ColorRect


var blueScoreText
var redScoreText
var blueScore = 0
var redScore = 0

func _ready():
	refresh_score()
	SceneController.connect("goalScored", self, "score_goal")
	
func score_goal(kicker):
	if kicker in get_tree().get_nodes_in_group("player_team"):
		blueScore += 1
	else:
		redScore += 1
		
	refresh_score()
	
func refresh_score():
	print(redScore)
	blueScoreText = "Blue: " + str(blueScore)
	redScoreText = "Red: " + str(redScore)
	$BlueScore.set_text(blueScoreText)
	$RedScore.set_text(redScoreText)
