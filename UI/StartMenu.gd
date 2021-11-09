extends Node2D
# StartMenu.gd 
# Primary controller script to handle functions of the initial load Start Menu, including background animations and music
#

onready var background = $ParallaxBackground as ParallaxBackground
onready var camera = $Camera2D as Camera2D

onready var topLeftPos = $TLeft as Position2D
onready var topRightPos = $TRight as Position2D
onready var botLeftPos = $BLeft as Position2D
onready var botRightPos = $BRight as Position2D

var bg_width := 145.0
var bg_height := 85.0
onready var plaxTween = Tween.new()
onready var rnd = RandomNumberGenerator.new()

func _ready():
	add_child(plaxTween)
	if not plaxTween.is_connected("tween_all_completed", self, "_start_camera_animation"):
		assert(plaxTween.connect("tween_all_completed", self, "_start_camera_animation") == OK)
	rnd.randomize()
	_start_camera_animation()
	
	pass # Replace with function body.

func _start_camera_animation() -> void:
	var targ_x: float = rnd.randf_range(topLeftPos.position.x,topRightPos.position.x)
	var targ_y: float = rnd.randf_range(topLeftPos.position.y, botRightPos.position.y)
	var camZoom = Vector2(2.1, 2.1)
	if camera.zoom.x >= 2.0:
		camZoom = Vector2(0.5, 0.5)
		
	plaxTween.interpolate_property(camera, "position:x", camera.position.x, targ_x, 10.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	plaxTween.interpolate_property(camera, "position:y", camera.position.y, targ_y, 10.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	plaxTween.interpolate_property(camera, "zoom", camera.zoom, camZoom, 10.0, Tween.TRANS_SINE, Tween.EASE_OUT)
#	plaxTween.interpolate_property(background, "scroll_offset:x", background.scroll_offset.x, targ_x, 4.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
#	plaxTween.interpolate_property(background, "scroll_offset:y", background.scroll_offset.y, targ_y, 4.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	plaxTween.start()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
