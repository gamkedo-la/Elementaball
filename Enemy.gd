extends KinematicBody2D


var HP = 20

func _process(delta):
	self.get_node("HP").text = ("HP:" + str(HP))
