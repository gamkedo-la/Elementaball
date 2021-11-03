extends KinematicBody2D

var velocity = Vector2()
var destination = Vector2()
var intercepting = false
var inDefenseZone = true
export var starting_stats : Resource
var type : String = "Type"
var HP : int
var maxHP = 50
var agility : int
var power : int
var speed : int

onready var ball = get_node("../Ball")

func _ready():
	initialize_stats(starting_stats)
	
func initialize_stats(stats : StartingStats):
	type = stats.type
	HP = stats.HP
	maxHP = stats.maxHP
	agility = stats.agility
	power = stats.power
	speed = stats.speed
	get_node("Health Bar").update_healthbar(maxHP)

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
	if(distance2Target > 20): 
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
	ball.possessionNode = get_node("Position2D")


func _on_InterceptArea_body_exited(body):
	if body.name == "Player" and ball.enemyPossession == false:
		intercepting = false


func _on_DefenseZone_body_entered(body):
	inDefenseZone = true


func _on_DefenseZone_body_exited(body):
	inDefenseZone = false
