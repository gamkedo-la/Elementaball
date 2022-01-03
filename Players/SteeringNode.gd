extends Node2D


onready var player = get_parent()
onready var boundary = get_node("../../Boundary Line")

onready var max_speed = 350
export var steer_force = 0.05
export var look_ahead = 100
export var num_rays = 8

# context array

var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO


func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		
func steer(delta):
	set_interest()
	set_danger()
	choose_direction()
	#Find the trajectory we'd like to be on
	var desired_velocity = (chosen_dir).normalized() * (max_speed/2)


	velocity = velocity.linear_interpolate(desired_velocity, steer_force)
	player.velocity = velocity
	update()

func find_final_heading(desired_velocity, delta):
		#How fast can we rotate each step (in degrees for now)
	var steer_speed = 15
	#What's the difference between my current position and my desired trajectorry?
	var relativeAngle = player.position.angle_to(desired_velocity)
	var magnitude
	#If the angle to where I want to go is large, I need to slow down and turn.
	if relativeAngle > -0.5 and relativeAngle < 0.5:
		magnitude = max_speed
	else:
		magnitude = max_speed/2
	 
	#If my desired path is to the left, turn left at my steering speed
	if relativeAngle < 0:
		steer_speed = -deg2rad(steer_speed)
		
		#
		velocity = transform.x * magnitude
		var newHeading = velocity.rotated(steer_speed) * delta
		newHeading = newHeading.normalized()
		velocity = newHeading * velocity.length()
	#If it's right, turn right
	elif relativeAngle > 0:
		steer_speed = deg2rad(steer_speed)
		#velocity.x = sin(steer_speed)*magnitude
		#velocity.y = cos(steer_speed)*magnitude
		velocity = transform.x * magnitude
		var newHeading = velocity.rotated(steer_speed) * delta
		newHeading = newHeading.normalized()
		velocity = newHeading * velocity.length()
	
func set_interest():
# Set interest in each slot based on world direction
	var path_direction : Vector2 = player.velocity
	var distance2Target = player.destination.distance_to(player.position)
	if distance2Target <= 16:
		path_direction = Vector2()
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(path_direction)
		interest[i] = max(1, d)
		
func set_danger():
	# Cast rays to find danger directions

	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(player.global_position,
				player.global_position + ray_directions[i].rotated(rotation) * look_ahead,
				[self, player, player.ball, boundary])
		danger[i] = 1.0 if result else 0.0
		
func choose_direction():
	# Eliminate interest in slots with danger

	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest

	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
	
func _draw():
	pass
	#for i in num_rays:
	#	draw_line(transform.x, ray_directions[i] * look_ahead, Color.purple)
	#	draw_line(transform.x, chosen_dir * look_ahead, Color.red)
	#	if interest[i]:
	#		draw_line(transform.x, ray_directions[i] * interest[i], Color.green)
	#	if danger[i]:
	#		draw_line(ray_directions[i] * interest[i], ray_directions[i] * (danger[i] * look_ahead), Color.yellow)
		
