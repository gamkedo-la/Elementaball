extends RigidBody2D

#Variables to signal what the player is doing
var dribbling = true
var kicking = false
var selecting = false

#Variables for abilities
var kickType
var kickedType
var tackleType = "Red"
var blockType
var blockedType
var target

#Variables for damage calculation phase
signal blocked
signal calculated
var totalDamage

#Enemy ball possession variables
var enemyPossession = false
var possessionNode

export var kickSpeed = 1

func _ready():
	# Called every time the node is added to the scene.
	set_physics_process(true)
	

func _physics_process(delta):
	if dribbling == true:
		player_dribbling()

	if enemyPossession == true:
		enemy_dribbling()
	
	if kicking == true:
		#TODO: Calculate the kick missing the goal
		check_kick_collisions()

		
func _input(event):
	if dribbling == true and Input.is_action_just_pressed("ui_kick") and selecting == false:
		player_kick()
		
	if enemyPossession == true and Input.is_action_just_pressed("ui_steal") and selecting == false:
		player_steal()

#TODO: Make player and enemy dribbling into one function, feed in thier dribbling position
func player_dribbling():
	#Stop the ball from colliding with things
	self.mode = RigidBody2D.MODE_KINEMATIC
	get_node("CollisionShape2D").disabled = true
	
	#Put the ball in the player's dribbling position
	self.position = get_node("../Player/Position2D").global_position

func enemy_dribbling():
	#Stop ball from colliding
	self.mode = RigidBody2D.MODE_KINEMATIC
	get_node("CollisionShape2D").disabled = true
	
	#Put the ball in the enemy's dribbling position
	self.position = possessionNode.global_position

func player_kick():
	dribbling = false
	
	#Bring up the Kick Menu
	selecting = true
	var kickMenu = get_node("../Popup/KickMenu")
	kickMenu.clear()
	var player = get_node("../Player")
	#Add the kick abilities available for the player to the menu
	#TODO: Make a default (no element) kick ability and calculate damage for it
	var abilities = [player.ability1,player.ability2,player.ability3,player.ability4]
	kickType = []
	for ability in abilities:
		if ability.action == "Kick":
			kickMenu.add_item(ability.name)
			kickType.append(ability.type)
	kickMenu.popup()
	kickMenu.rect_position = get_node("../Player/Position2D").global_position

func player_steal():
	#If player is colliding with an enemy, that enemy becomes the target
	if get_node("../Player")._check_player_collisions("Enemy") != null:
		target = get_node("../Player")._check_player_collisions("Enemy")
		
		#Bring up the Tackle Menu to let the player choose an ability
		selecting = true
		var tackleMenu = get_node("../Popup/TackleMenu")
		tackleMenu.clear()
		var player = get_node("../Player")
		#Add the tackle abilities available for the player to the menu
		#TODO: Make a default (no element) tackle ability and calculate damage for it
		var abilities = [player.ability1,player.ability2,player.ability3,player.ability4]
		tackleType = []
		for ability in abilities:
			if ability.action == "Tackle":
				tackleMenu.add_item(ability.name)
				tackleType.append(ability.type)
		tackleMenu.popup()
		tackleMenu.rect_position = get_node("../Player/Position2D").global_position

func player_block(tackleType):
	selecting = true
	dribbling = false
	
	var blockMenu = get_node("../Popup/BlockMenu")
	blockMenu.clear()
	var player = get_node("../Player")
	#Add the block abilities available for the player to the menu
	#TODO: Make a default (no element) block ability and calculate damage reduction for it
	var abilities = [player.ability1,player.ability2,player.ability3,player.ability4]
	blockType = []
	for ability in abilities:
		if ability.action == "Block":
			blockMenu.add_item(ability.name)
			blockType.append(ability.type)
		blockMenu.popup()
		blockMenu.rect_position = get_node("../Player/Position2D").global_position	
		
	yield(self, "blocked")
		
	var damageReduction = calc_damage_reduction(tackleType)
	totalDamage = (totalDamage * damageReduction)
	target.HP -= totalDamage	
	target.get_node("Health Bar").update_healthbar(target.HP)
	emit_signal("calculated")

func check_kick_collisions():
	var bodies=get_colliding_bodies()
	if bodies.size() > 0:
		for body in bodies:
			#If the enemy intercepts the ball, calculate damage and give possession to enemy.
			#TODO: Calculate Enemy failing their interception and the results
			if "Enemy" in body.name:
				calc_intercept_damage(body)
			
			#TODO: If ball collides with goal, score a point
			if body.name == "Goal":
				score_goal()

func score_goal():
	kicking = false
	self.get_node("Sprite").visible = false

func _on_KickMenu_id_pressed(id):
	kicking = true
	get_node("CollisionShape2D").disabled = false
	
	if kickType[id] == "Green":
		get_node("Sprite").modulate = Color(0,255,0)
		kickedType = "Green"
	if kickType[id] == "Red":
		get_node("Sprite").modulate = Color(255,0,0)
		kickedType = "Red"
	if kickType[id] == "Blue":
		get_node("Sprite").modulate = Color(0,0,255)
		kickedType = "Blue"
	self.mode = RigidBody2D.MODE_RIGID
	var goal_position = get_node("../Goal").position
	self.linear_velocity = ((goal_position - self.position) * kickSpeed)
	selecting = false

func calc_intercept_damage(interceptor):
	var baseDamage = 10
	totalDamage = calc_element_damage(kickedType, interceptor.type, baseDamage)
	interceptor.HP -= totalDamage	
	interceptor.get_node("Health Bar").update_healthbar(interceptor.HP)
	kicking = false
	enemyPossession = true
	possessionNode = interceptor.get_node("Position2D")
	interceptor.intercepting = false

func _on_TackleMenu_id_pressed(id):
	calc_tackle_damage(tackleType[id])
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
		enemyPossession = false
		dribbling = true
	else:
		player_block(tackledType)
	
func _on_BlockMenu_id_pressed(id):
	blockedType = blockType[id]
	selecting = false
	emit_signal("blocked")
	
func calc_element_damage(attackType, defenderType, baseDamage):
	var totalDamage
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
	return totalDamage
	
func calc_damage_reduction(attackType):
	var damageReduction
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
