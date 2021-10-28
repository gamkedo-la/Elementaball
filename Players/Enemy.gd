extends KinematicBody2D

var velocity = Vector2()
var destination = Vector2()
var intercepting = false
var inDefenseZone = true
export var speed = 150
var HP = 50

onready var ball = get_node("../Ball")

func _process(delta):
	self.get_node("HP").text = ("HP:" + str(HP))

func _physics_process(delta):	
	#if the enemy's defense range collides with the ball
	if intercepting == true:
		destination = ball.global_position
		#the enemy moves toward the ball TODO: while blocking own goal
		velocity = (destination-self.position).normalized()*speed;
		_move_to_target()
			
	#TODO if ball is out of range, returns to assigned zone
	else:
		if(inDefenseZone == false): 
			destination = get_node("../DefenseZone").global_position
			velocity = (destination-self.position).normalized()*speed; 
			_move_to_target()
		else:
			#TODO moves between ball and their own goal within assigned zone
			velocity = (self.position).normalized()*speed; 
			
		

func _check_collisions():
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		return collider.name
		
func _move_to_target():
	var distance2Target = destination.distance_to(self.position); 
	if(distance2Target > 5): 
		move_and_slide(velocity);
	elif (destination == ball.global_position and ball.kicking == false):
		_try_steal();

func _on_InterceptArea_body_entered(body):
	if body.name == "Player" and ball.enemyPossession == false:
		intercepting = true
		
func _try_steal():
	intercepting = false
	ball.kicking = false
	ball.dribbling = false
	ball.enemyPossession = true


func _on_InterceptArea_body_exited(body):
	if body.name == "Player" and ball.enemyPossession == false:
		intercepting = false


func _on_DefenseZone_body_entered(body):
	inDefenseZone = true


func _on_DefenseZone_body_exited(body):
	inDefenseZone = false
