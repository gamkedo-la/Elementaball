extends AnimatedSprite

onready var TargetNode = get_node("../Ball")

func _process(_delta):
	self.transform.origin = TargetNode.transform.origin
	
	if TargetNode.linear_velocity:
		look_at(transform.origin + TargetNode.linear_velocity)
