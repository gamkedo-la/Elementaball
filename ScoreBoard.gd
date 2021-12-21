extends ColorRect


var blueScoreText
var redScoreText
var blueScore = 0
var redScore = 0
var blueKO = 0
var redKO = 0

func _ready():
	refresh_score()
# warning-ignore:return_value_discarded
	SceneController.connect("goalScored", self, "score_goal")
# warning-ignore:return_value_discarded
	SceneController.connect("knockout", self, "record_KO")
	
func score_goal(kicker):
	if kicker in get_tree().get_nodes_in_group("player_team"):
		blueScore += 1
	else:
		redScore += 1
		
	refresh_score()

func record_KO(team):
	if team == "blue":
		blueKO += 1
	else:
		redKO += 1
	
	if blueKO >= 3:
		SceneController.emit_signal("allKO","red")
		
	if redKO >= 3:
		SceneController.emit_signal("allKO","blue")
	
func refresh_score():
	blueScoreText = "Blue: " + str(blueScore)
	redScoreText = "Red: " + str(redScore)
	get_node("HBoxContainer/BlueScore").set_text(blueScoreText)
	get_node("HBoxContainer/RedScore").set_text(redScoreText)
