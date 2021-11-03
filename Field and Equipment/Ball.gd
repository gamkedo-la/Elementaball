extends RigidBody2D


var dribbling = true
var kicking = false
var selecting = false
var kickID
var target
var blockType
signal blocked
signal calculated
var totalDamage
var goal = false
var enemyPossession = false
var possessionNode
export var kickSpeed = 1

func _ready():
	# Called every time the node is added to the scene.
	set_physics_process(true)
	

func _physics_process(delta):
	if dribbling == true:
		self.mode = RigidBody2D.MODE_KINEMATIC
		get_node("CollisionShape2D").disabled = true
		self.position = get_node("../Player/Position2D").global_position

	if enemyPossession == true:
		self.mode = RigidBody2D.MODE_KINEMATIC
		get_node("CollisionShape2D").disabled = true
		self.position = possessionNode.global_position
	
	if kicking == true:
		var bodies=get_colliding_bodies()
		if bodies.size() > 0:
			for body in bodies:
				if "Enemy" in body.name:
					calc_intercept_damage(body)
				if body.name == "Goal":
					kicking = false
					goal = true
					
	if goal == true:
		self.get_node("Sprite").visible = false
		
func _input(event):
	if dribbling == true and Input.is_action_just_pressed("ui_kick") and selecting == false:
		dribbling = false
		selecting = true
		get_node("../Popup/KickMenu").popup()
		get_node("../Popup/KickMenu").rect_position = get_node("../Player/Position2D").global_position
		
	if enemyPossession == true and Input.is_action_just_pressed("ui_steal") and selecting == false:
		if get_node("../Player")._check_collisions("Enemy") != null:
			target = get_node("../Player")._check_collisions("Enemy")
			selecting = true
			get_node("../Popup/TackleMenu").popup()
			get_node("../Popup/TackleMenu").rect_position = get_node("../Player/Position2D").global_position

func _on_KickMenu_id_pressed(id):
	kicking = true
	get_node("CollisionShape2D").disabled = false
	kickID = id
	#TODO get these kicks to pass variables identifying what type they are so a function can calculate the damage
	if id == 0:
		get_node("Sprite").modulate = Color(0,255,0)
	if id == 1:
		get_node("Sprite").modulate = Color(255,0,0)
	if id == 2:
		get_node("Sprite").modulate = Color(0,0,255)
	self.mode = RigidBody2D.MODE_RIGID
	var goal_position = get_node("../Goal").position
	self.linear_velocity = ((goal_position - self.position) * kickSpeed)
	selecting = false

func calc_intercept_damage(interceptor):
	var kickType
	var baseDamage = 10
	#TODO: These need to be changed to take in the type of the ability selected
	if kickID == 0:
		kickType = "Green"
	if kickID == 1:
		kickType = "Red"
	if kickID == 2:
		kickType = "Blue"
	
	totalDamage = calc_element_damage(kickType, interceptor.type, baseDamage)
	interceptor.HP -= totalDamage	
	interceptor.get_node("Health Bar").update_healthbar(interceptor.HP)
	kicking = false
	enemyPossession = true
	possessionNode = interceptor.get_node("Position2D")
	interceptor.intercepting = false

func _on_TackleMenu_id_pressed(id):
	var tackleType
	#TODO: These need to be changed to take in the type of the ability selected
	if id == 0:
		tackleType = "Green"
	if id == 1:
		tackleType = "Blue"
	if id == 2:
		tackleType = "Red"
	calc_tackle_damage(tackleType)
	selecting = false
	
func calc_tackle_damage(tackleType):
	var baseDamage = 5
	totalDamage = calc_element_damage(tackleType, target.type, baseDamage)
	
	#if enemy is tackling the player, they have a chance to defend. TODO: Allow AI to defend as well
	if enemyPossession == true:
		emit_signal("calculated")
		target.HP -= totalDamage	
		target.get_node("Health Bar").update_healthbar(target.HP)
		target.start_steal_cooldown()
		enemyPossession = false
		dribbling = true
	else:
		selecting = true
		dribbling = false
		get_node("../Popup/BlockMenu").popup()
		get_node("../Popup/BlockMenu").rect_position = get_node("../Player/Position2D").global_position
		
		yield(self, "blocked")
		
		var damageReduction = calc_damage_reduction(tackleType, blockType)
		totalDamage = (totalDamage * damageReduction)
		target.HP -= totalDamage	
		target.get_node("Health Bar").update_healthbar(target.HP)
		emit_signal("calculated")
	
func _on_BlockMenu_id_pressed(id):
	#TODO: These need to be changed to take in the type of the ability selected
	if id == 0:
		blockType = "Green"
	if id == 1:
		blockType = "Blue"
	if id == 2:
		blockType = "Red"
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
	
func calc_damage_reduction(attackType, blockType):
	var damageReduction
	if attackType == "Green" and blockType == "Green":
		damageReduction = 0.75
	elif attackType == "Green" and blockType == "Red":
		damageReduction = 0.5
	elif attackType == "Green" and blockType == "Blue":
		damageReduction = 1
	elif attackType == "Red" and blockType == "Green":
		damageReduction = 1
	elif attackType == "Red" and blockType == "Red":
		damageReduction = 0.75
	elif attackType == "Red" and blockType == "Blue":
		damageReduction = 0.5
	elif attackType == "Blue" and blockType == "Green":
		damageReduction = 0.5
	elif attackType == "Blue" and blockType == "Red":
		damageReduction = 1
	elif attackType == "Blue" and blockType == "Blue":
		damageReduction = 0.75
	return damageReduction
