extends Area2D


func _process(delta):
	self.position = get_node("../Ball").position
