extends RigidBody2D

#Variables to signal what the player is doing
var groundball = true
var outOfBounds = false
var throwingIn = false
var dribbling = false
var kicking = false
var attacker
var blocker
var selecting = false
var goalScoring = false

#Variables for abilities
var menuAbilities = []
var kickedType
var blockedType
var target
var ballEffects

#Variables for damage calculation phase
signal blocked
signal calculated
var totalDamage

#Enemy ball possession variables
var enemyPossession = false
var possessionNode
var playerInPossession
var lastInPossession
onready var controllingPlayer = get_node("../Player")

export var kickSpeed = 500

func _ready():
	ballEffects = get_node("../BallEffects")
# warning-ignore:return_value_discarded
	SceneController.connect("inPossession", self, "set_possession")
# warning-ignore:return_value_discarded
	SceneController.connect("controlling", self, "set_control")
	set_physics_process(true)
	

func _physics_process(_delta):
	if dribbling == true:
		dribbling()

	if enemyPossession == true:
		dribbling()
	
	if kicking == true:
		check_kick_collisions()
		
	if groundball == true:
		check_groundball_collisions()
		
	update()

#Just for debugging if needed.
func _draw():
	pass

		
func _input(_event):
	if playerInPossession == controllingPlayer and Input.is_action_just_pressed("ui_kick") and selecting == false:
		player_kick()
		
	if playerInPossession == controllingPlayer and Input.is_action_just_pressed("ui_pass") and selecting == false:
		player_pass()
		
	if enemyPossession == true and Input.is_action_just_pressed("ui_steal") and selecting == false:
		player_steal()

func set_possession(player):
	playerInPossession = player
	if player != null:
		ballEffects.visible = false
		if player.is_in_group("player_team"):
			lastInPossession = "player_team"
		else:
			lastInPossession = "enemy_team"
		possessionNode = player.get_node("ThingsToFlip/Position2D")
		if player in get_tree().get_nodes_in_group("player_team"):
			dribbling = true
			enemyPossession = false
		else:
			enemyPossession = true
			dribbling = false
	else:
		enemyPossession = false
		dribbling = false
	
	
func set_control(player):
	controllingPlayer = player

func dribbling():
	#Stop the ball from colliding with things
	self.mode = RigidBody2D.MODE_KINEMATIC
	get_node("CollisionShape2D").disabled = true
	
	#Put the ball in the player's dribbling position
	self.global_transform.origin = possessionNode.get_global_position()

func player_kick():
	#Bring up the Kick Menu
	selecting = true
	var kickMenu = get_node("../Popup/KickMenu")
	kickMenu.clear()
	var player = playerInPossession
	#Add the kick abilities available for the player to the menu
	#TODO: Make a default (no element) kick ability and calculate damage for it
	var abilities = [player.ability1,player.ability2,player.ability3,player.ability4,player.defaultKick]
	menuAbilities = []
	if abilities.size() > 0:
		for ability in abilities:
			if ability != null and ability.action == "Kick":
				kickMenu.add_item(ability.name)
				menuAbilities.append(ability)
	kickMenu.popup()
	kickMenu.rect_position = playerInPossession.global_position
	
func player_pass():
	#Bring up the Kick Menu
	selecting = true
	var kickMenu = get_node("../Popup/PassMenu")
	kickMenu.clear()
	var player = playerInPossession
	#Add the kick abilities available for the player to the menu
	#TODO: Make a default (no element) kick ability and calculate damage for it
	var abilities = [player.ability1,player.ability2,player.ability3,player.ability4, player.defaultKick]
	menuAbilities = []
	for ability in abilities:
		if ability != null and ability.action == "Kick":
			kickMenu.add_item(ability.name)
			menuAbilities.append(ability)
	kickMenu.popup()
	kickMenu.rect_position = playerInPossession.global_position

func player_steal():
	controllingPlayer._try_steal()

func player_block(tackledType):
	selecting = true
	
	var blockMenu = get_node("../Popup/BlockMenu")
	blockMenu.clear()
	var player = controllingPlayer
	#Add the block abilities available for the player to the menu
	#TODO: Make a default (no element) block ability and calculate damage reduction for it
	var abilities = [player.ability1,player.ability2,player.ability3,player.ability4,player.defaultBlock]
	menuAbilities = []
	if abilities.size() > 0:
		for ability in abilities:
			if ability != null and ability.action == "Block":
				blockMenu.add_item(ability.name)
				menuAbilities.append(ability)
	blockMenu.popup()
	blockMenu.rect_position = controllingPlayer.global_position	
	
	SceneController.emit_signal("blocking", true)	
	yield(self, "blocked")
		
	var damageReduction = calc_damage_reduction(tackledType)
	totalDamage = ((totalDamage * damageReduction) - blocker.power)
	if totalDamage <= 0:
		totalDamage = 1
	target.HP -= totalDamage	
	target.get_node("Health Bar").update_healthbar(target.HP)
	emit_signal("calculated")

func check_groundball_collisions():
	var bodies=get_colliding_bodies()
	if bodies.size() > 0:
		for body in bodies:
			if "Player" in body.name or "Enemy" in body.name:
				groundball = false
				SceneController.emit_signal("inPossession", body)

func check_kick_collisions():
	var bodies=get_colliding_bodies()
	if bodies.size() > 0:
		for body in bodies:
			#If the enemy intercepts the ball, calculate damage and give possession to enemy.
			#TODO: Calculate Enemy failing their interception and the results
			if ("Player" in body.name or "Enemy" in body.name) and body != attacker:
				if attacker:
					if attacker.myTeam != body.myTeam:
						calc_intercept_damage(body)
					else:
						kicking = false
						SceneController.emit_signal("inPossession", body)
				else:
					kicking = false
					SceneController.emit_signal("inPossession", body)
					body.intercepting = false

func out_of_bounds():
	outOfBounds = true
	print("out of bounds")
	SceneController.emit_signal("outOfBounds")

func score_goal(goal):
	SceneController.emit_signal("goalScored", goal)
	out_of_bounds()
	goalScoring = false

func _on_KickMenu_id_pressed(id):
	initialize_kick(id)
	
	#Calculate where the shot will go and whether it hits or misses
	var goal_position
	var miss_position1
	var miss_position2
	var possibleShots = []
	if attacker in get_tree().get_nodes_in_group("player_team"):
		goal_position = get_node("../Goal").global_position
		miss_position1 = get_node("../Goal/Position2D").global_position
		miss_position2 = get_node("../Goal/Position2D2").global_position
	else:
		goal_position = get_node("../Enemy Goal").global_position
		miss_position1 = get_node("../Enemy Goal/Position2D").global_position
		miss_position2 = get_node("../Enemy Goal/Position2D2").global_position
		
	possibleShots = [goal_position, miss_position1, miss_position2]
	#TODO make odds of hitting the goal position better based on player speed stat
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var shotIndex = rng.randf_range(0, 2)
	SceneController.emit_signal("inPossession", null)
	kicking = true
	get_node("../Throw In Boundary/CollisionPolygon2D").disabled = true
	self.mode = RigidBody2D.MODE_RIGID
	get_node("CollisionShape2D").disabled = false
	set_linear_velocity((possibleShots[shotIndex] - self.global_position).normalized() * kickSpeed)
	#apply_torque_impulse(rng.randf_range(500, 2000))

func _on_PassMenu_id_pressed(id, kicker = playerInPossession):
	initialize_kick(id)
	
	var openTeammates = get_tree().get_nodes_in_group(kicker.myTeam)
	for player in openTeammates:
		if player == kicker:
			openTeammates.erase(player)
	var nearestMate
	var mateDistance = 99999
	for player in openTeammates:
		if player.position.distance_to(kicker.position) < mateDistance:
			mateDistance = player.position.distance_to(kicker.position)
			nearestMate = player
	if nearestMate == null:
		nearestMate = kicker.myGoal
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	SceneController.emit_signal("inPossession", null)
	kicking = true
	get_node("../Throw In Boundary/CollisionPolygon2D").disabled = true
	self.mode = RigidBody2D.MODE_RIGID
	set_linear_velocity((nearestMate.position - self.global_position).normalized() * kickSpeed)
	#apply_torque_impulse(rng.randf_range(500, 2000))
	yield(get_tree().create_timer(0.1), "timeout")
	get_node("CollisionShape2D").disabled = false
	
	
func initialize_kick(id):
	selecting = false
	attacker = find_attacker("kick")
	
	if menuAbilities[id].type == "None":
		kickedType = "None"
	if menuAbilities[id].type == "Green":
		ballEffects.visible = true
		ballEffects.animation = "plant ball"
		kickedType = "Green"
	if menuAbilities[id].type == "Red":
		ballEffects.visible = true
		ballEffects.animation = "fire ball"
		kickedType = "Red"
	if menuAbilities[id].type == "Blue":
		ballEffects.visible = true
		ballEffects.animation = "water ball"
		kickedType = "Blue"
		
	AudioQueen.emit_signal("playSound", menuAbilities[id].sound)

func find_attacker(attackAction):
	if attackAction == "kick":
		#Find player in possession
		return playerInPossession
	if attackAction == "tackle":
		#Find player being controlled
		return controllingPlayer

func find_blocker():
	return controllingPlayer

func calc_intercept_damage(interceptor):
	var baseDamage = 10
	baseDamage = calc_power_modifier(baseDamage)
	totalDamage = calc_element_damage(kickedType, interceptor.type, baseDamage)
	interceptor.HP -= totalDamage	
	interceptor.get_node("Health Bar").update_healthbar(interceptor.HP)
	kicking = false
	SceneController.emit_signal("inPossession", interceptor)

func _on_TackleMenu_id_pressed(id):
	AudioQueen.emit_signal("playSound", menuAbilities[id].sound)
	attacker = find_attacker("tackle")
	calc_tackle_damage(menuAbilities[id].type)
	yield(get_tree(), "idle_frame")
	selecting = false
	
func calc_tackle_damage(tackledType):
	var baseDamage = 5
	totalDamage = calc_element_damage(tackledType, target.type, baseDamage)
	
	#if enemy is tackling the player, they have a chance to defend. TODO: Allow AI to defend as well
	if enemyPossession == true:
		emit_signal("calculated")
		target.HP -= totalDamage	
		target.get_node("Health Bar").update_healthbar(target.HP)
		target.start_steal_cooldown()
		SceneController.emit_signal("inPossession", controllingPlayer)
	else:
		player_block(tackledType)
	
func _on_BlockMenu_id_pressed(id):
	AudioQueen.emit_signal("playSound", menuAbilities[id].sound)
	blocker = find_blocker()
	blockedType = menuAbilities[id].type
	selecting = false
	emit_signal("blocked")
	SceneController.emit_signal("blocking", false)

func calc_power_modifier(baseDamage):
	if attacker:
		baseDamage += attacker.power
	return baseDamage
	
func calc_element_damage(attackType, defenderType, baseDamage):
	if attackType == "Green" and defenderType == "Green":
		totalDamage = baseDamage
	elif attackType == "Green" and defenderType == "Red":
		totalDamage = (baseDamage/2)
	elif attackType == "Green" and defenderType == "Blue":
		totalDamage = (baseDamage*2)
	elif attackType == "Red" and defenderType == "Green":
		totalDamage = (baseDamage*2)
	elif attackType == "Red" and defenderType == "Red":
		totalDamage = baseDamage
	elif attackType == "Red" and defenderType == "Blue":
		totalDamage = (baseDamage/2)
	elif attackType == "Blue" and defenderType == "Green":
		totalDamage = (baseDamage/2)
	elif attackType == "Blue" and defenderType == "Red":
		totalDamage = (baseDamage*2)
	elif attackType == "Blue" and defenderType == "Blue":
		totalDamage = baseDamage
	else:
		totalDamage = baseDamage
	return totalDamage
	
func calc_damage_reduction(attackType):
	var damageReduction = 0.9
	if attackType == "Green" and blockedType == "Green":
		damageReduction = 0.75
	elif attackType == "Green" and blockedType == "Red":
		damageReduction = 0.5
	elif attackType == "Green" and blockedType == "Blue":
		damageReduction = 1
	elif attackType == "Red" and blockedType == "Green":
		damageReduction = 1
	elif attackType == "Red" and blockedType == "Red":
		damageReduction = 0.75
	elif attackType == "Red" and blockedType == "Blue":
		damageReduction = 0.5
	elif attackType == "Blue" and blockedType == "Green":
		damageReduction = 0.5
	elif attackType == "Blue" and blockedType == "Red":
		damageReduction = 1
	elif attackType == "Blue" and blockedType == "Blue":
		damageReduction = 0.75
	return damageReduction

func _on_Boundary_Line_body_entered(body):
	if throwingIn and outOfBounds:
		if body == self and playerInPossession == null:
			outOfBounds = false
			yield(get_tree().create_timer(1.0), "timeout")
			for player in get_tree().get_nodes_in_group("all_players"): 
				player.outOfBounds = false
			throwingIn = false
	elif body.is_in_group("all_players") and body.offField == true:
		body.offField = false

func _on_Boundary_Line_body_exited(body):			
	if not outOfBounds:
		if body.is_in_group("all_players") and body.inPossession:
			out_of_bounds()
		elif body.is_in_group("all_players") and body.offField == false:
			body.offField = true
		if body == self and playerInPossession == null:
			out_of_bounds()

func _on_GoalBoundaryDetector_body_entered(body):
	if "Goal" in body.name:
		if goalScoring == false:
			goalScoring = true
			score_goal(body)



