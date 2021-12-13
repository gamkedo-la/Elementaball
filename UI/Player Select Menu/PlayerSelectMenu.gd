extends Control

export(Array, Resource) var selectablePlayers
export(Array, Resource) var selectablePitches

var pitchIndex = 0
var centerIndex = 0
var leftIndex = 0
var rightIndex = 0

onready var centerSprite = get_node("SelectionMenuPopup/SelectionMenuContainer/PlayersContainer/CenterFieldSprite")
onready var centerText = get_node("SelectionMenuPopup/SelectionMenuContainer/PlayersContainer/CenterFieldSelect/Label")
onready var centerPlayer = get_node("../../Player")

onready var leftSprite = get_node("SelectionMenuPopup/SelectionMenuContainer/PlayersContainer/VBoxContainer/LeftField/LeftFieldSprite")
onready var leftText = get_node("SelectionMenuPopup/SelectionMenuContainer/PlayersContainer/VBoxContainer/LeftField/LeftFieldSelect/Label")
onready var leftPlayer = get_node("../../Player2")

onready var rightSprite = get_node("SelectionMenuPopup/SelectionMenuContainer/PlayersContainer/VBoxContainer/RightField/RightFieldSprite")
onready var rightText = get_node("SelectionMenuPopup/SelectionMenuContainer/PlayersContainer/VBoxContainer/RightField/RightFieldSelect/Label")
onready var rightPlayer = get_node("../../Player3")

onready var pitchSprite = get_node("SelectionMenuPopup/SelectionMenuContainer/MarginContainer3/TopRowContainer/FieldImage")
onready var pitchText = get_node("SelectionMenuPopup/SelectionMenuContainer/PitchSelect/Label")
onready var gamePitch = get_node("../../ParallaxBackground/Sprite")

var main

func _ready():
	get_tree().paused = true
	$SelectionMenuPopup.show()

func _on_CenterFieldSelect_change(direction):
	centerIndex += direction
	if centerIndex > 2:
		centerIndex = 0
	centerSprite.texture = selectablePlayers[centerIndex].sprite
	centerText.text = selectablePlayers[centerIndex].speciesName
	centerPlayer.starting_stats = selectablePlayers[centerIndex]
	centerPlayer.initialize_stats(centerPlayer.starting_stats)


func _on_RightFieldSelect_change(direction):
	rightIndex += direction
	if rightIndex > 2:
		rightIndex = 0
	rightSprite.texture = selectablePlayers[rightIndex].sprite
	rightText.text = selectablePlayers[rightIndex].speciesName
	rightPlayer.starting_stats = selectablePlayers[rightIndex]
	rightPlayer.initialize_stats(rightPlayer.starting_stats)
	

func _on_LeftFieldSelect_change(direction):
	leftIndex += direction
	if leftIndex > 2:
		leftIndex = 0
	leftSprite.texture = selectablePlayers[leftIndex].sprite
	leftText.text = selectablePlayers[leftIndex].speciesName
	leftPlayer.starting_stats = selectablePlayers[leftIndex]
	leftPlayer.initialize_stats(leftPlayer.starting_stats)


func _on_CloseButton_pressed():
	$SelectionMenuPopup.hide()
	get_tree().paused = false


func _on_PitchSelect_change(direction):
	pitchIndex += direction
	if pitchIndex > selectablePitches.size() - 1:
		pitchIndex = 0
	pitchSprite.texture = selectablePitches[pitchIndex].sprite
	gamePitch.texture = pitchSprite.texture
	pitchText.text = selectablePitches[pitchIndex].name
