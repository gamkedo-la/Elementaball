extends Node

#All the players on the field
var playerCenter
var playerLeft
var playerRight
var enemyCenter
var enemyLeft
var enemyRight

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
	enemyLeft = get_node("../Enemy2")
	enemyRight = get_node("../Enemy3")
	
	playerTeam = [playerCenter, playerLeft, playerRight]
	enemyTeam = [enemyCenter, enemyLeft, enemyRight]
	allPlayers = [playerCenter, playerLeft, playerRight, enemyCenter, enemyLeft, enemyRight]

func _process(delta):
	if Input.is_action_pressed("ui_exit"):
		get_tree().quit()
