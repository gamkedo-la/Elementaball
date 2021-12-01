extends "res://Players/AIPlayer.gd"

var motion = Vector2()
var beingTackled = false
var playerTeam = []

func _ready():
	playerTeam = get_tree().get_nodes_in_group("player_team")

func _check_player_collisions(collider_name):
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		if collider_name in collider.name:
			return collider
		else:
			return null
			
