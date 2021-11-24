extends Node2D

signal playSound(sound)

func _ready():
	connect("playSound", self, "play_sound")

func play_sound(sound):
	if has_node(sound):
		get_node(sound).play()
