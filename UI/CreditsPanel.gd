extends PopupPanel


onready var backButton = get_node("VBoxContainer/BackButton")
signal creditsClosing()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	self.hide()
	self.emit_signal("creditsClosing")


func _on_CreditsButton_pressed():
	self.show()
	backButton.grab_focus()
