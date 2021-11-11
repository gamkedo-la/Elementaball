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
	SceneController.connect("controlling", self, "set_targets")
	set_targets(get_node("../Player"))

func _process(delta):
	if !targets:
		return
	# Keep the camera centered between the targets

	var pos = Vector2.ZERO
	for target in targets:
		pos += target.position
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
	if not player in targets:
		targets = [player, ball]
	print(targets)

func add_target(target):
	if not target in targets:
		targets.append(target)

func remove_target(target):
	if target in targets:
		targets.remove(target)
