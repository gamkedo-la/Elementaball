extends Control

export(Array, Resource) var selectablePlayers
export(Array, Resource) var selectablePitches

export var closeButton : NodePath
export var startButton : NodePath

var pitchIndex = 0
var centerIndex = 0
var leftIndex = 0
var rightIndex = 0

signal centerSpriteChange (sprite)
signal leftSpriteChange (sprite)
signal rightSpriteChange (sprite)

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
	get_node(closeButton).grab_focus()
	centerPlayer.starting_stats = selectablePlayers[centerIndex]
	centerPlayer.initialize_stats(centerPlayer.starting_stats)
	rightPlayer.starting_stats = selectablePlayers[rightIndex]
	rightPlayer.initialize_stats(rightPlayer.starting_stats)
	leftPlayer.starting_stats = selectablePlayers[leftIndex]
	leftPlayer.initialize_stats(leftPlayer.starting_stats)

func _on_CenterFieldSelect_change(direction, buttons):
	centerIndex += direction
	if centerIndex > selectablePlayers.size() - 1:
		centerIndex = 0
	if centerIndex < 0:
		centerIndex = selectablePlayers.size() - 1
	centerSprite.texture = selectablePlayers[centerIndex].sprite
	emit_signal("centerSpriteChange", selectablePlayers[centerIndex].sprite)
	buttons.get_node("Label").text = selectablePlayers[centerIndex].speciesName
	centerPlayer.starting_stats = selectablePlayers[centerIndex]
	centerPlayer.initialize_stats(centerPlayer.starting_stats)


func _on_RightFieldSelect_change(direction, buttons):
	rightIndex += direction
	if rightIndex > selectablePlayers.size() - 1:
		rightIndex = 0
	if rightIndex < 0:
		rightIndex = selectablePlayers.size() - 1
	rightSprite.texture = selectablePlayers[rightIndex].sprite
	emit_signal("rightSpriteChange", selectablePlayers[rightIndex].sprite)
	buttons.get_node("Label").text = selectablePlayers[rightIndex].speciesName
	rightPlayer.starting_stats = selectablePlayers[rightIndex]
	rightPlayer.initialize_stats(rightPlayer.starting_stats)
	

func _on_LeftFieldSelect_change(direction, buttons):
	leftIndex += direction
	if leftIndex > selectablePlayers.size() - 1:
		leftIndex = 0
	if leftIndex < 0:
		leftIndex = selectablePlayers.size() - 1
	leftSprite.texture = selectablePlayers[leftIndex].sprite
	emit_signal("leftSpriteChange", selectablePlayers[leftIndex].sprite)
	buttons.get_node("Label").text = selectablePlayers[leftIndex].speciesName
	leftPlayer.starting_stats = selectablePlayers[leftIndex]
	leftPlayer.initialize_stats(leftPlayer.starting_stats)

func _on_PitchSelect_change(direction, buttons):
	pitchIndex += direction
	if pitchIndex > selectablePitches.size() - 1:
		pitchIndex = 0
	if pitchIndex < 0:
		pitchIndex = selectablePitches.size() - 1
	pitchSprite.texture = selectablePitches[pitchIndex].sprite
	gamePitch.texture = pitchSprite.texture
	buttons.get_node("Label").text = selectablePitches[pitchIndex].name
	
func _on_CloseButton_pressed():
	$SelectionMenuPopup.hide()
	$AbilityMenuPopup.show()	
	get_node(startButton).grab_focus()

func _on_StartButton_pressed():
	$AbilityMenuPopup.hide()
	get_tree().paused = false
