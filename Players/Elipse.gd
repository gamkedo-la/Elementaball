extends Sprite


export var elipse : Texture
export var controllingElipse : Texture


# Called when the node enters the scene tree for the first time.
func _ready():
	SceneController.connect("controlling", self, "set_elipse")
	if get_parent() == get_node("../../Player"):
		self.texture = controllingElipse


func set_elipse(player):
	if player == get_parent():
		self.texture = controllingElipse
	else:
		self.texture = elipse
