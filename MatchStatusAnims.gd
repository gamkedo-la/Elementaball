extends AnimatedSprite


onready var ball = get_node("../../Ball")
var animationTree


# Called when the node enters the scene tree for the first time.
func _ready():
	SceneController.connect("goalScored", self, "goal_scored")
	SceneController.connect("outOfBounds", self, "out")
	SceneController.connect("knockout", self, "KO")
	animationTree = $AnimationTree.get("parameters/playback")


func goal_scored(_goal):
	animationTree.travel("Goal")

func KO(_player, _team):
	animationTree.travel("KO")
	
func out():
	if !ball.goalScoring and !ball.KO:
		animationTree.travel("Out")
	ball.goalScoring = false
	ball.KO = false
