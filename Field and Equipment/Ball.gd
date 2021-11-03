extends RigidBody2D


var dribbling = true
var kicking = false
var selecting = false
var kickID
var target
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
			enemyPossession = false
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
	var totalDamage
	if kickID == 0:
		kickType = "green"
	if kickID == 1:
		kickType = "red"
	if kickID == 2:
		kickType = "blue"
	
	if kickType == "green" and interceptor.type == "Green":
		totalDamage = baseDamage
	elif kickType == "green" and interceptor.type == "Red":
		totalDamage = (baseDamage/2)
	elif kickType == "green" and interceptor.type == "Blue":
		totalDamage = (baseDamage*2)
	elif kickType == "red" and interceptor.type == "Green":
		totalDamage = (baseDamage*2)
	elif kickType == "red" and interceptor.type == "Red":
		totalDamage = baseDamage
	elif kickType == "red" and interceptor.type == "Blue":
		totalDamage = (baseDamage/2)
	if kickType == "blue" and interceptor.type == "Green":
		totalDamage = (baseDamage/2)
	elif kickType == "blue" and interceptor.type == "Red":
		totalDamage = (baseDamage*2)
	elif kickType == "blue" and interceptor.type == "Blue":
		totalDamage = baseDamage
	
	interceptor.HP -= totalDamage	
	interceptor.get_node("Health Bar").update_healthbar(interceptor.HP)
	kicking = false
	enemyPossession = true
	possessionNode = interceptor.get_node("Position2D")
	interceptor.intercepting = false

func _on_TackleMenu_id_pressed(id):
	kickID = id
	if id == 0:
		target.HP -= 20
	if id == 1:
		target.HP -= 10
	if id == 2:
		target.HP -= 5
	target.get_node("Health Bar").update_healthbar(target.HP)
	selecting = false
	dribbling = true
	enemyPossession = false

