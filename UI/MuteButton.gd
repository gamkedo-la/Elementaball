extends ToolButton

var muted = false

func _on_MuteButton_pressed():
	self.muted = !self.muted
	
	if (self.muted):
		print("SOUND MUTED")
	else:
		print("SOUND ENABLED")
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), self.muted)

	# example of how sounds get played
	# AudioQueen.emit_signal("playSound", menuAbilities[id].sound)
