extends KinematicBody2D

var motion = Vector2()
export var speed = 300

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

func _check_collisions():
	if get_slide_count() != 0 :
		for i in range (0,get_slide_count()) :
			return(get_slide_collision(i))
