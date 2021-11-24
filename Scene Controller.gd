extends Node

signal goalScored(kicker)
signal inPossession(player)
signal controlling(player)
signal tackling(trueOrFalse)
signal blocking(trueOrFalse)

#All the players on the field
var playerCenter
var playerLeft
var playerRight
var enemyCenter
var enemyLeft
var enemyRight
var playerIndex = 0

#Array of the player controlled team
var playerTeam = []

#Array of the enemy team
var enemyTeam = []

#Array of all players
var allPlayers = []

func _ready():
	set_process(true)
	playerTeam = get_tree().get_nodes_in_group("player_team")

func _process(delta):
	if Input.is_action_pressed("ui_exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("ui_next_player"):
		playerIndex += 1
		if playerIndex > 2:
			playerIndex = 0
		emit_signal("controlling", playerTeam[playerIndex])
