extends RigidBody2D


var dribbling = true
var kicking = false
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
				if body.name == "Enemy":
					if kickID == 0:
						body.HP -= 20
					if kickID == 1:
						body.HP -= 5
					if kickID == 2:
						body.HP -= 10
					kicking = false
					enemyPossession = true
					possessionNode = body.get_node("Position2D")
					body.intercepting = false
				if body.name == "Goal":
					kicking = false
					goal = true
	if goal == true:
		self.get_node("Sprite").visible = false
		
func _input(event):
	if dribbling == true and Input.is_action_just_pressed("ui_kick"):
		dribbling = false
		get_node("../Popup/KickMenu").popup()
		get_node("../Popup/KickMenu").rect_position = get_node("../Player/Position2D").global_position
	if enemyPossession == true and Input.is_action_just_pressed("ui_kick"):
		if get_node("../Player")._check_collisions("Enemy") != null:
			target = get_node("../Player")._check_collisions("Enemy")
			enemyPossession = false
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


func _on_TackleMenu_id_pressed(id):
	kickID = id
	if id == 0:
		target.HP -= 20
	if id == 1:
		target.HP -= 10
	if id == 2:
		target.HP -= 5
	dribbling = true