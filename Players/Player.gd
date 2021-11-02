extends KinematicBody2D

var motion = Vector2()
export var speed = 300
var HP = 50
var maxHP = 50

func _physics_process(delta):
	if get_node("../Ball").dribbling == true or get_node("../Ball").enemyPossession == true:
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
	else:
		motion.x = 0
		motion.y = 0
		
	move_and_slide(motion)

func _check_collisions(collider_name):
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		if collider_name in collider.name:
			return collider
		else:
			return null
			
