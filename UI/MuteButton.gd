extends ToolButton

var muted = false

func _process(delta):
	if Input.is_action_pressed("ui_mute"):
		_on_MuteButton_pressed()

func _on_MuteButton_pressed():
	self.muted = !self.muted
	
	if (self.muted):
		print("SOUND MUTED")
	else:
		print("SOUND ENABLED")
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), self.muted)

	# example of how sounds get played
	# AudioQueen.emit_signal("playSound", menuAbilities[id].sound)
