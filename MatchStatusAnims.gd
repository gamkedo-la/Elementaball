extends AnimatedSprite


onready var ball = get_node("../../Ball")
var animationTree


# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("goalScored", self, "goal_scored")
# warning-ignore:return_value_discarded
	SceneController.connect("outOfBounds", self, "out")
# warning-ignore:return_value_discarded
	SceneController.connect("knockout", self, "KO")
	animationTree = $AnimationTree.get("parameters/playback")


func goal_scored(_goal):
	animationTree.travel("Goal")

func KO(_player, _team):
	animationTree.travel("KO")
	
func out():
	if !ball.goalScoring and !ball.KO:
		animationTree.travel("Out")
	elif ball.goalScoring:
		ball.goalScoring = false
	elif ball.KO:
		ball.KO = false
