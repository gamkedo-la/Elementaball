extends ToolButton

var muted = false
export var mutedIcon : Texture
export var unmutedIcon : Texture


func _process(_delta):
	if Input.is_action_pressed("ui_mute"):
		_on_MuteButton_pressed()

func _on_MuteButton_pressed():
	self.muted = !self.muted
	
	if (self.muted):
		self.icon = mutedIcon
	else:
		self.icon = unmutedIcon
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), self.muted)

	# example of how sounds get played
	# AudioQueen.emit_signal("playSound", menuAbilities[id].sound)
