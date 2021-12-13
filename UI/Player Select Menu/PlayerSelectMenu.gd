extends Control

export(Array, Resource) var selectablePlayers

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

onready var pitchSprite = get_node("SelectionMenuPopup/SelectionMenuContainer/TopRowContainer/FieldImage")

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
	print(get_node("../../Player2").type)


func _on_CloseButton_pressed():
	$SelectionMenuPopup.hide()
	get_tree().paused = false


func _on_PitchSelect_change(direction):
	pass
