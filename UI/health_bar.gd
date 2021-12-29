extends Control

var barRed = preload("res://Art/UI/health_bar_red.png")
var barGreen = preload("res://Art/UI/health_bar_green.png")
var barYellow = preload("res://Art/UI/health_bar_yellow.png")

onready var healthbar = get_node("Health Bar")
onready var animPlayer = get_node("StatusAnimations")

func _ready():
	update_healthbar(healthbar.max_value)

func update_healthbar(value):
	if get_parent() and get_parent().get("maxHP"):
		healthbar.max_value = get_parent().maxHP
	healthbar.texture_progress = barGreen
	if value < healthbar.max_value * 0.7:
		healthbar.texture_progress = barYellow
	if value < healthbar.max_value * 0.35:
		healthbar.texture_progress = barRed
	healthbar.value = value
	if healthbar.value <= 0:
		animPlayer.visible = true
		animPlayer.animation = "KO"
		animPlayer.frame = 0
		animPlayer.playing = true
		yield(animPlayer,"animation_finished")
		if get_parent().is_in_group("player_team"):
			SceneController.emit_signal("knockout", get_parent(), "blue")
		else:
			SceneController.emit_signal("knockout", get_parent(), "red")
		get_parent().get_node("EnemyCollider").disabled = true
		if get_parent().controlling:
			SceneController.next_player()
		if get_parent().inPossession:
			SceneController.emit_signal("inPossession", null)
		get_parent().queue_free()


