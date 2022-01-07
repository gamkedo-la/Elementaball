extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("champion", self, "set_champion")

func set_champion():
	self.text = "You've won all four matches! You're league champion!!!"
