extends "res://Players/AIPlayer.gd"

var motion = Vector2()
var beingTackled = false
var playerTeam = []

func _ready():
	playerTeam = get_tree().get_nodes_in_group("player_team")
	
#This handles player motion. The other actions are calculated in the Ball script.
func _physics_process(_delta):
	if controlling == true and get_node("../Ball").selecting == false:
		if Input.is_action_pressed("ui_right"):
			motion.x = speed
		
		elif Input.is_action_pressed("ui_left"):
			motion.x = -speed
		
		elif Input.is_action_pressed("ui_up"):
			motion.y = -speed
		
		elif Input.is_action_pressed("ui_down"):
			motion.y = speed
		else:
			motion.x = 0
			motion.y = 0
		
		move_and_slide(motion)

func _check_player_collisions(collider_name):
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		if collider_name in collider.name:
			return collider
		else:
			return null
			
