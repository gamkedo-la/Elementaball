extends Control

export(Array, Resource) var selectablePlayers

var pitchIndex = 0
var centerIndex = 0
var leftIndex = 0
var rightIndex = 0

onready var centerSprite = get_node("CanvasLayer/SelectionMenuContainer/PlayersContainer/CenterFieldSprite")
onready var centerText = get_node("CanvasLayer/SelectionMenuContainer/PlayersContainer/CenterFieldSelect/Label")
onready var centerPlayer = get_node("../Player")

func _on_CenterFieldSelect_change(direction):
	centerIndex += direction
	if centerIndex > 2:
		centerIndex = 0
	centerSprite.texture = selectablePlayers[centerIndex].sprite
	centerText.text = selectablePlayers[centerIndex].speciesName
	centerPlayer.starting_stats = selectablePlayers[centerIndex]
	centerPlayer.initialize_stats(centerPlayer.starting_stats)
