extends AnimatedSprite


onready var ball = get_node("../../Ball")
var animationTree


# Called when the node enters the scene tree for the first time.
func _ready():
	SceneController.connect("goalScored", self, "goal_scored")
	SceneController.connect("outOfBounds", self, "out")
	animationTree = $AnimationTree.get("parameters/playback")


func goal_scored(goal):
	print("goal")
	animationTree.travel("Goal")
	
func out():
	if !ball.goalScoring:
		animationTree.travel("Out")
	ball.goalScoring = false
