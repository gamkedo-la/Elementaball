extends KinematicBody2D

var motion = Vector2()
var beingTackled = false

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

func _ready():
	initialize_stats(starting_stats)

#TODO Combine with enemy scene so both player controls and AI are available to all players on the field	
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

#This handles player motion. The other actions are calculated in the Ball script.
func _physics_process(delta):
	if (get_node("../Ball").dribbling == true or get_node("../Ball").enemyPossession == true):
		if Input.is_action_pressed("ui_right"):
			motion.x = speed
		
		elif Input.is_action_pressed("ui_left"):
			motion.x = -speed
		
		elif Input.is_action_pressed("ui_up"):
			motion.y = -speed
		
		elif Input.is_action_pressed("ui_down"):
			motion.y = speed
		else:
			motion.x = 0
			motion.y = 0
	else:
		motion.x = 0
		motion.y = 0
		
	move_and_slide(motion)

func _check_collisions(collider_name):
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		if collider_name in collider.name:
			return collider
		else:
			return null
			
