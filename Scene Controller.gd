extends Node

signal goalScored(kicker)
signal inPossession(player)
signal controlling(player)
signal tackling(trueOrFalse)
signal blocking(trueOrFalse)
signal outOfBounds()

var playerIndex = 0

#Array of the player controlled team
var playerTeam = []

#Array of the enemy team
var enemyTeam = []

#Array of all players
var allPlayers = []

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_process(true)
	playerTeam = get_tree().get_nodes_in_group("player_team")
	connect("inPossession", self, "possession_control")

func _process(_delta):
	if Input.is_action_pressed("ui_exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("ui_next_player"):
		playerTeam = get_tree().get_nodes_in_group("player_team")
		playerIndex += 1
		if playerIndex > 2:
			playerIndex = 0
		emit_signal("controlling", playerTeam[playerIndex])

func possession_control(player):
	if player in playerTeam:
		emit_signal("controlling", player)
