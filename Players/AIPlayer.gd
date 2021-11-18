extends KinematicBody2D

#Variables for movement
var velocity = Vector2.ZERO
var destination = Vector2()
var previousPosition = global_position

#States for defense
var intercepting = false
var inDefenseZone = true
var tacklingInProgress = false
var tacklerIsSelf = false
var stealCooldown = false
var defenseZone

#States for offense
export var controlling = false
export var inPossession = false
var timer

export var fieldPosition : String

#All the starting stats from the Starting Stats class of resources
export var starting_stats : Resource
var characterName : String = "Name"
var type : String = "Type"
var HP : int
var maxHP = 50
var agility : int
var power : int
export var speed : int
var ability1 : Resource
var ability2 : Resource
var ability3 : Resource
var ability4 : Resource

#All the animation stats
var animStates: Resource
var idleAnim : String
var runningAnim : String
var tackleAnim : String
var kickAnim : String
var aniMachine

onready var ball = get_node("../Ball")

func _ready():
	initialize_stats(starting_stats)
	defenseZone = get_node("../" + fieldPosition)
	SceneController.connect("inPossession", self, "set_possession")
	SceneController.connect("controlling", self, "set_control")
	SceneController.connect("tackling", self, "toggle_tackling")
	aniMachine = $AnimationTree["parameters/playback"]
	
		
func initialize_stats(stats : StartingStats):
	characterName = stats.characterName
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
	
	animStates = stats.animStates
	
	if self.is_in_group("enemy_team"):
		characterName = characterName + " Enemy"
	
	idleAnim = characterName + " Idle"
	runningAnim = characterName + " Run"
	tackleAnim = characterName + " Tackle"
	kickAnim = characterName + " Kick"
	
	get_node("Health Bar").update_healthbar(maxHP)

func _physics_process(delta):
	if controlling == false:
		
		#if the enemy's defense range collides with the ball
		if intercepting == true:
			intercept()
			
		#TODO if ball is out of range, returns to assigned zone
		else:
			defend_zone()
		update()
		#TODO: Add offensive AI - running toward goal, passing, kicking
	
	if tacklingInProgress and tacklerIsSelf:
		aniMachine.travel(tackleAnim)
	elif velocity.length() == 0:
		aniMachine.travel(idleAnim)
	elif velocity.length() > 0:
		aniMachine.travel(runningAnim)

func defend_zone():
	if(inDefenseZone == false): 
		destination = defenseZone.global_position
		velocity = (destination-self.position).normalized()*speed; 
		_move_to_target("defenseZone")
	else:
		#TODO moves between ball and their own goal within assigned zone
		velocity = Vector2.ZERO

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


func intercept(type = "normal"):
	if destination == to_local(ball.playerInPossession.global_position):
		_move_to_target("tackle")
	elif destination != to_local(ball.global_position):
		reset_intercept()
	else:
		velocity = (destination-Vector2.ZERO).normalized()*speed;
		_move_to_target("intercept")

func _move_to_target(targetType):
	var distance2Target = destination.distance_to(Vector2.ZERO);
	var ballPosition = to_local(ball.global_position)
	if(destination != ballPosition and distance2Target > 10): 
		move_and_slide(velocity);
	elif(destination == ballPosition  and distance2Target > 50): 
		move_and_slide(velocity);
	elif (targetType == "intercept" and destination != to_local(ball.global_position)):
		destination = ballPosition 
	elif (destination == ballPosition and ball.kicking == false and stealCooldown == false):
		_try_steal();
	elif distance2Target > 5:
		move_and_slide(velocity)
	else: velocity = Vector2.ZERO
		

func _try_steal():
	tacklerIsSelf = true
	stealCooldown = true
	SceneController.emit_signal("tackling", true)
	ball.target = ball.playerInPossession
	destination = to_local(ball.playerInPossession.global_position)
	aniMachine.travel(tackleAnim)

func toggle_tackling(trueOrFalse):
		tacklingInProgress = trueOrFalse

func tackle_ended():
	if inPossession == false:
		tacklerIsSelf = false
		SceneController.emit_signal("tackling", false)
		reset_intercept()
		
func reset_intercept():
	#TODO make this player find their own goal
	var goalPosition = Vector2()
	goalPosition = get_node("../Goal").global_position
	destination = Geometry.get_closest_point_to_segment_2d (Vector2.ZERO, to_local(ball.position), to_local(goalPosition))
	#the enemy moves toward the ball TODO: while blocking own goal
	velocity = (destination-Vector2.ZERO).normalized()*speed;
	_move_to_target("intercept")
	
func check_steal():
	if _check_collisions() and ("Player" in _check_collisions() or "Ball" in _check_collisions()):
		ball.calc_tackle_damage(type)
		yield(ball, "calculated")
		intercepting = false
		tacklerIsSelf = false
		SceneController.emit_signal("inPossession", self)
		SceneController.emit_signal("tackling", false)
	start_steal_cooldown()

func start_steal_cooldown():
	var cooldownTimer = get_tree().create_timer(2.0)
	yield(cooldownTimer, "timeout")
	stealCooldown = false

func _on_InterceptArea_body_entered(body):
	if body == ball.playerInPossession and ball.enemyPossession == false:
		intercepting = true

func _on_InterceptArea_body_exited(body):
	if body == ball.playerInPossession and ball.enemyPossession == false:
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
		

