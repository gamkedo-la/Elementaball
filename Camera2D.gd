extends Camera2D

export var move_speed = 0.5  # camera position lerp speed

export var zoom_speed = 0.25  # camera zoom lerp speed

export var min_zoom = 1.5  # camera won't zoom closer than this

export var max_zoom = 3  # camera won't zoom farther than this

export var margin = Vector2(400, 200)  # include some buffer area around targets



var ball
var targets = []  # Array of targets to be tracked.


onready var screen_size = get_viewport_rect().size

func _ready():
	ball = get_node("../Ball")
	add_target(ball)
# warning-ignore:return_value_discarded
	SceneController.connect("controlling", self, "set_targets")
	SceneController.connect("inPossession", self, "set_targets")
	SceneController.connect("knockout", self, "remove_target")
	set_targets(get_node("../Player"))

func _process(_delta):
	yield(get_tree(), "idle_frame")
	if !targets:
		return
	# Keep the camera centered between the targets

	var pos = Vector2.ZERO
	for target in targets:
		if target != null: 
			if target.position != null:
				pos += target.get_position()
	pos /= targets.size()
	position = lerp(position, pos, move_speed)
	
	# Find the zoom that will contain all targets
	var rect = Rect2(position, Vector2.ONE)
	for target in targets:
		rect = rect.expand(target.position)
	rect = rect.grow_individual(margin.x, margin.y, margin.x, margin.y)
	var zoomTarget
	if rect.size.x > rect.size.y * screen_size.aspect():
		zoomTarget = clamp(rect.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		zoomTarget = clamp(rect.size.y / screen_size.y, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * zoomTarget, zoom_speed)

func set_targets(player):
	if player:
		if player.inPossession:
			targets = [player, player.myGoal]
		else:
			targets = [player, ball]
		set_process(true)

func add_target(target):
	if not target in targets:
		targets.append(target)

func remove_target(target, team):
	if target in targets:
		targets.erase(target)
	if !ball in targets:
		add_target(ball)
