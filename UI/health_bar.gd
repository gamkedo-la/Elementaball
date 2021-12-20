extends Control

var barRed = preload("res://Art/UI/health_bar_red.png")
var barGreen = preload("res://Art/UI/health_bar_green.png")
var barYellow = preload("res://Art/UI/health_bar_yellow.png")

onready var healthbar = get_node("Health Bar")

func _ready():
	if get_parent() and get_parent().get("maxHP"):
		healthbar.max_value = get_parent().maxHP
		update_healthbar(healthbar.max_value)

func update_healthbar(value):
	healthbar.texture_progress = barGreen
	if value < healthbar.max_value * 0.7:
		healthbar.texture_progress = barYellow
	if value < healthbar.max_value * 0.35:
		healthbar.texture_progress = barRed
	if value <= 0:
		if get_parent() == get_node("../../Ball").playerInPossession:
			SceneController.emit_signal("inPossession", null)
		get_parent().queue_free()
	healthbar.value = value
