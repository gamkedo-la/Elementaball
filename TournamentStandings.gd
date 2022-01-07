extends Node2D

var mixedPitch = false
var greenPitch = false
var bluePitch = false
var redPitch = false
var selectedPitch

func _ready():
# warning-ignore:return_value_discarded
	SceneController.connect("pitchSet", self, "set_pitch")
# warning-ignore:return_value_discarded
	SceneController.connect("winner", self, "save_win")

func set_pitch(pitch):
	selectedPitch = pitch
	
func save_win(winner):
	if winner == "Blue":
		if selectedPitch == "Blue":
			bluePitch = true
		if selectedPitch == "Red":
			redPitch = true
		if selectedPitch == "Green":
			greenPitch = true
		if selectedPitch == "Mixed":
			mixedPitch = true
		get_node("../SaveSystem").save_game()
	var allPitches = [bluePitch, redPitch, greenPitch, mixedPitch]
	var wins = 0
	for pitch in allPitches:
		if pitch == true:
			wins += 1
	if wins >= 4:
		SceneController.emit_signal("champion") 

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"mixedPitch" : mixedPitch,
		"greenPitch" : greenPitch,
		"bluePitch" : bluePitch,
		"redPitch" : redPitch
	}
	return save_dict
