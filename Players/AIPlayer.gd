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
var myTeam
export var controlling = false
export var inPossession = false
var possessionPosition
var go2Secondary = false #Has receivers alternate between a primary and secondary position
var timer

var outOfBounds = false
var throwInPlayer
var throwInPoint

export var fieldPosition : String
var rng = RandomNumberGenerator.new()
var randomDistanceX = 0
var randomDistanceY = 0

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
	SceneController.connect("outOfBounds", self, "out_of_bounds")
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
		myTeam = "enemy_team"
		myGoal = get_node("../Enemy Goal")
	else:
		myOpponent = "enemy_team"
		myTeam = "player_team"
		myGoal = get_node("../Goal")
	
	idleAnim = characterName + " Idle"
	runningAnim = characterName + " Run"
	tackleAnim = characterName + " Tackle"
	kickAnim = characterName + " Kick"
	
	get_node("Health Bar").update_healthbar(maxHP)

func _physics_process(_delta):
	if outOfBounds:
		if throwInPlayer == self:
			translate(to_local(throwInPoint))
			SceneController.emit_signal("inPossession", self)
			if controlling == false:
				yield(get_tree().create_timer(3.0), "timeout")
				if ball.throwingIn == false and controlling == false:
					ball.throwingIn = true
					try_pass()
					for player in get_tree().get_nodes_in_group("all_players"): 
						player.outOfBounds = false
					yield(get_tree().create_timer(1.0), "timeout")
				
		if onOffense and throwInPlayer != self:
			get_in_position()
			
		if onDefense: 
			defend_zone()
		
		if controlling == false:
			velocity = move_and_slide(velocity)
			
	elif controlling == false and ball.selecting == false:
		
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
	var distanceFromPossession = possessionPosition.distance_to(self.position)
	if distanceFromPossession >= 200:
		try_pass()	
	elif distance2Goal <= 200:
		try_kick()
	
	destination = Vector2(myGoal.position.x, self.position.y)
	velocity = (destination-self.position).normalized()*speed
	check_and_slide()
	
func get_in_position():
	var myZoneY = defenseZone.position.y
	var goal2Ball = Vector2(ball.position.x, myZoneY).distance_to(Vector2(myGoal.position.x, myZoneY))
	var distance2Dest = position.distance_to(destination)
	var leftOrRight
	
	if myTeam == "player_team":
		leftOrRight = 1
	else:
		leftOrRight = -1
	
	if distance2Dest <= 64:
		go2Secondary = not go2Secondary
		rng.randomize()
		randomDistanceX = rng.randi_range(50, 125)
		randomDistanceY = rng.randi_range(50, 125)
		if "PlayerRight" in defenseZone.name or "EnemyLeft" in defenseZone.name:
			randomDistanceY = -randomDistanceY
	if ball.playerInPossession:
		if go2Secondary:
			destination = Vector2((ball.playerInPossession.position.x + randomDistanceX + goal2Ball/2)*leftOrRight, myZoneY+randomDistanceY)
		else:
			destination = Vector2((ball.playerInPossession.position.x + randomDistanceX + goal2Ball/10)*leftOrRight, myZoneY+randomDistanceY)
		
	velocity = (destination-self.position).normalized()*(speed/2)
	check_and_slide()

func defend_zone():
	destination = defenseZone.get_node("Path2D").curve.get_closest_point(ball.position)
	
	velocity = (destination-self.position).normalized()*speed;	
	check_and_slide()

func set_possession(player):
	if player == self:
		inPossession = true
		possessionPosition = self.position
	else:
		inPossession = false
	
	if player != null: 
		if player.is_in_group(myOpponent):
			onDefense = true
			onOffense = false
		else:
			onDefense = false
			onOffense = true
			intercepting = false
	else:
		onDefense = false
		onOffense = false
		
func set_control(player):
	if player == self:
		controlling = true
	else:
		controlling = false

func out_of_bounds():
	if outOfBounds == false:
		outOfBounds = true
		var throwInTeam
		if ball.lastInPossession.is_in_group("player_team"):
			throwInTeam = "enemy_team"
			if self.is_in_group("player_team"):
				onDefense = true
				onOffense = false
			if self.is_in_group("enemy_team"):
				onOffense = true
				onDefense = false
		else:
			throwInTeam = "player_team" 
			if self.is_in_group("player_team"):
				onDefense = false
				onOffense = true
			if self.is_in_group("enemy_team"):
				onOffense = false
				onDefense = true
		
		var closestDistance = 9999
		var closestPlayer
		for player in get_tree().get_nodes_in_group(throwInTeam):
			if player.position.distance_to(ball.position) < closestDistance:
				closestDistance = player.position.distance_to(ball.position)
				closestPlayer = player
				
		throwInPlayer = closestPlayer
		
		closestDistance = 9999
		var closestPosition
		for point in get_tree().get_nodes_in_group("throw_in_positions"):
			if point.position.distance_to(ball.position) < closestDistance:
				closestDistance = point.position.distance_to(ball.position)
				closestPosition = point
				
		throwInPoint = closestPosition.position

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
	prekick()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var moveChosen = rng.randi_range(0, ball.menuAbilities.size()-1)
	ball._on_KickMenu_id_pressed(moveChosen)

func try_pass():
	prekick()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var moveChosen = rng.randi_range(0, ball.menuAbilities.size()-1)
	ball._on_PassMenu_id_pressed(moveChosen, self)
	
func find_receiver():
	var openTeammates = get_tree().get_nodes_in_group(myTeam)
	for player in openTeammates:
		if player == self:
			openTeammates.erase(player)

	for player in openTeammates:
		var matePosition = player.position.distance_to(myGoal.position)
		var myPosition = self.position.distance_to(myGoal.position)
		if matePosition < myPosition:
			return true
	return false

func prekick():
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
		

