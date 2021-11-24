extends KinematicBody2D

#Variables for movement
var velocity = Vector2()
onready var initialScale = scale
var destination = Vector2()
var previousPosition = position

#States for defense
var onDefense = false
var intercepting = false
var tacklingInProgress = false
var blockingInProgress = false
var tacklerIsSelf = false
var stealCooldown = false
var defenseZone
var myOpponent = "opposing_team"

#States for offense
var onOffense = false
var myGoal
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
	SceneController.connect("blocking", self, "toggle_blocking")
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
		myOpponent = "player_team"
		myGoal = get_node("../Enemy Goal")
	else:
		myOpponent = "enemy_team"
		myGoal = get_node("../Goal")
	
	idleAnim = characterName + " Idle"
	runningAnim = characterName + " Run"
	tackleAnim = characterName + " Tackle"
	kickAnim = characterName + " Kick"
	
	get_node("Health Bar").update_healthbar(maxHP)

func _physics_process(_delta):
	if controlling == false and ball.selecting == false:
		
		#If nobody has the ball, try to get it.
		if !ball.playerInPossession:
			destination = ball.position
			velocity = (destination-self.position).normalized()*speed;
		
		#TODO add offense states
		if onOffense:
			if inPossession:
				pass_and_shoot()
			else:
				get_in_position()
		
		if onDefense:
			#if the enemy's defense range collides with the ball
			if intercepting == true:
				#print("intercepting")
				intercept()
			
			#If ball is out of range, returns to assigned zone
			else:
				defend_zone()
			update()
			
		velocity = move_and_slide(velocity)
		
		if velocity.x > 0.1:
			$ThingsToFlip.scale.x = -1
			if has_node("EnemyCollider"): # players don't have this
				$EnemyCollider.scale.x = -1
		
		elif velocity.x < -0.1:
			$ThingsToFlip.scale.x = 1
			if has_node("EnemyCollider"): # players don't have this
				$EnemyCollider.scale.x = 1

	if tacklingInProgress and tacklerIsSelf:
		aniMachine.travel(tackleAnim)
	elif velocity.length() == 0:
		aniMachine.travel(idleAnim)
	elif velocity.length() > 0:
		aniMachine.travel(runningAnim)

func pass_and_shoot():
	var distance2Goal = position.distance_to(myGoal.position)
	if distance2Goal >= 300:
		destination = Vector2(myGoal.position.x, self.position.y)
		velocity = (destination-self.position).normalized()*speed
	elif distance2Goal <= 50:
		try_kick()
	
	check_and_slide()
	
func get_in_position():
	var distance2Goal = position.distance_to(myGoal.position)
	var myZoneY = defenseZone.position.y
	if distance2Goal >= 300:
		destination = Vector2(myGoal.position.x, myZoneY)
		velocity = (destination-self.position).normalized()*speed
	else:
		destination = Vector2(myGoal.position.x, myZoneY)
		velocity = (destination-self.position).normalized()*speed
	
	check_and_slide()

func defend_zone():
	destination = defenseZone.get_node("Path2D").curve.get_closest_point(ball.position)
	
	velocity = (destination-self.position).normalized()*speed;	
	check_and_slide()

func set_possession(player):
	if player == self:
		inPossession = true
	else:
		inPossession = false
	
	if player != null and player.is_in_group(myOpponent):
		onDefense = true
		onOffense = false
	else:
		onDefense = false
		onOffense = true
		
func set_control(player):
	if player == self:
		controlling = true
	else:
		controlling = false

func intercept():
	if destination != ball.position and destination != ball.playerInPossession.position:
		reset_intercept()
	else:
		_move_to_target()

func _move_to_target():
	var distance2Target = destination.distance_to(self.position);
	var ballPosition = ball.position
	if ball.playerInPossession:
		if (distance2Target <= 32 and destination != ballPosition):
			destination = ballPosition
			check_and_slide()
		elif distance2Target >= 32:
			check_and_slide()
		elif (destination == ballPosition and ball.kicking == false and stealCooldown == false and tacklingInProgress == false):
			_try_steal();
	else: check_and_slide()
		
func check_and_slide(distance2Target = destination.distance_to(self.position), delta = get_physics_process_delta_time()):
	if distance2Target >= velocity.length() * delta:
		return
	else:
		velocity = Vector2()

func try_kick():
	if ball.kicking == false:
		#Bring up the Kick Menu
		var kickMenu = get_node("../Popup/KickMenu")
		kickMenu.clear()
		var player = self
		#Add the kick abilities available for the player to the menu
		#TODO: Make a default (no element) kick ability and calculate damage for it
		var abilities = [player.ability1,player.ability2,player.ability3,player.ability4]
		ball.menuAbilities = []
		for ability in abilities:
			if ability.action == "Kick":
				kickMenu.add_item(ability.name)
				ball.menuAbilities.append(ability)
		ball._on_KickMenu_id_pressed(0)

func _try_steal():
	tacklerIsSelf = true
	stealCooldown = true
	SceneController.emit_signal("tackling", true)
	ball.target = ball.playerInPossession
	destination = ball.playerInPossession.position
	check_and_slide()
	aniMachine.travel(tackleAnim)

func toggle_tackling(trueOrFalse):
		tacklingInProgress = trueOrFalse
		
func toggle_blocking(trueOrFalse):
		blockingInProgress = trueOrFalse

func tackle_ended():
	if inPossession == false:
		if blockingInProgress:
			yield(SceneController, "blocking")
		tacklerIsSelf = false
		SceneController.emit_signal("tackling", false)
		reset_intercept()
		
func reset_intercept():
	var goalPosition = Vector2()
	goalPosition = myGoal.position
	destination = Geometry.get_closest_point_to_segment_2d (self.position, ball.position, goalPosition)
	#the enemy moves toward the ball
	velocity = (destination-self.position).normalized()*speed;
	_move_to_target()
	
func check_steal():
	#print("checking for successful steal")
	if _check_collisions() and _check_collisions().is_in_group(myOpponent):
		#print("steal successful")
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
	if body == ball.playerInPossession and body.is_in_group(myOpponent):
		intercepting = true

func _on_InterceptArea_body_exited(body):
	if body == ball.playerInPossession and body.is_in_group(myOpponent):
		intercepting = false
	
func _check_collisions():
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		return collider
		

