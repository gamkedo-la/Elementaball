extends KinematicBody2D

var velocity = Vector2()
var destination = Vector2()
var intercepting = false
export var speed = 300
var HP = 50

func _process(delta):
	self.get_node("HP").text = ("HP:" + str(HP))

func _physics_process(delta):	
	#if the ball's range collides with the enemy
	if intercepting == true:
		#the enemy moves toward the ball TODO: while blocking own goal
		velocity = (destination-self.position).normalized()*speed;
		
		move_and_slide(velocity);
	#TODO if ball is out of range, returns to assigned zone

	#TODO moves between ball and their own goal within assigned zone
	
		

func _check_collisions():
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		return collider.name

func _on_InterceptArea_body_entered(body):
	if body.name == "Enemy":
		intercepting = true
		destination = get_node("../Ball").global_position
