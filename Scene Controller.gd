extends Node

signal goalScored(kicker)
signal inPossession(player)
signal controlling(player)

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
	playerCenter = get_node("../Player")
	playerLeft = get_node("../Player2")
	playerRight = get_node("../Player3")
	enemyCenter = get_node("../Enemy")
	enemyLeft = get_node("../Enemy3")
	enemyRight = get_node("../Enemy2")
	
	playerTeam = get_tree().get_nodes_in_group("player_team")
	enemyTeam = [enemyCenter, enemyLeft, enemyRight]
	allPlayers = [playerCenter, playerLeft, playerRight, enemyCenter, enemyLeft, enemyRight]

func _process(delta):
	if Input.is_action_pressed("ui_exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("ui_next_player"):
		playerIndex += 1
		if playerIndex > 2:
			playerIndex = 0
		emit_signal("controlling", playerTeam[playerIndex])
		print(playerIndex)
