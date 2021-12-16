extends Node2D

# warning-ignore:unused_signal
signal playSound(sound)

func _ready():
# warning-ignore:return_value_discarded
	connect("playSound", self, "play_sound")

func play_sound(sound):
	if has_node(sound):
		get_node(sound).play()
