extends KinematicBody2D

#Variables for movement
var velocity = Vector2()
var destination = Vector2()

#States for defense
var intercepting = false
var inDefenseZone = true
var stealCooldown = false
var defenseZone

#States for offense
export var controlling = false
export var inPossession = false

export var fieldPosition : String

#All the starting stats from the Starting Stats class of resources
export var starting_stats : Resource
var type : String = "Type"
var HP : int
var maxHP = 50
var agility : int
var power : int
var speed : int
var ability1 : Resource
var ability2 : Resource
var ability3 : Resource
var ability4 : Resource

onready var ball = get_node("../Ball")

func _ready():
	initialize_stats(starting_stats)
	defenseZone = get_node("../" + fieldPosition)
	SceneController.connect("inPossession", self, "set_possession")
	SceneController.connect("controlling", self, "set_control")
	if controlling:
		SceneController.emit_signal("controlling", self)
		
func initialize_stats(stats : StartingStats):
	type = stats.type
	HP = stats.HP
	maxHP = stats.maxHP
	agility = stats.agility
	power = stats.power
	speed = stats.speed
	ability1 = stats.ability1
	ability2 = stats.ability2
	ability3 = stats.ability3
	ability4 = stats.ability4
	
	get_node("Health Bar").update_healthbar(maxHP)

func _physics_process(delta):	
	if controlling == false:
		#if the enemy's defense range collides with the ball
		if intercepting == true:
			intercept()
			
		#TODO if ball is out of range, returns to assigned zone
		else:
			defend_zone() 
		
		#TODO: Add offensive AI - running toward goal, passing, kicking
		
func defend_zone():
	if(inDefenseZone == false): 
		destination = defenseZone.global_position
		velocity = (destination-self.position).normalized()*speed; 
		_move_to_target()
	else:
		#TODO moves between ball and their own goal within assigned zone
		velocity = (self.position).normalized()*speed;

func set_possession(player):
	if player == self:
		inPossession = true
	else:
		inPossession = false
		
func set_control(player):
	if player == self:
		controlling = true
	else:
		controlling = false


func intercept():
	destination = ball.global_position
	#the enemy moves toward the ball TODO: while blocking own goal
	velocity = (destination-self.position).normalized()*speed;
	_move_to_target()

func _try_steal():
	stealCooldown = true
	ball.target = get_node("../Player")
	ball.calc_tackle_damage(type)
	yield(ball, "calculated")
	intercepting = false
	ball.kicking = false
	ball.dribbling = false
	SceneController.emit_signal("inPossession", self)
	ball.enemyPossession = true
	start_steal_cooldown()

func start_steal_cooldown():
	stealCooldown = true
	var cooldownTimer = get_tree().create_timer(5.0)
	yield(cooldownTimer, "timeout")
	stealCooldown = false

func _on_InterceptArea_body_entered(body):
	if body.name == "Player" and ball.enemyPossession == false:
		intercepting = true

func _on_InterceptArea_body_exited(body):
	if body.name == "Player" and ball.enemyPossession == false:
		intercepting = false

func _on_DefenseZone_body_entered(body):
	inDefenseZone = true
	
func _on_DefenseZone_body_exited(body):
	inDefenseZone = false
	
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
	elif (destination == ball.global_position and ball.kicking == false and stealCooldown == false):
		_try_steal();
