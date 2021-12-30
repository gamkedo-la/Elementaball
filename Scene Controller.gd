extends Node

# warning-ignore:unused_signal
signal goalScored(goal)
# warning-ignore:unused_signal
signal inPossession(player)
signal controlling(player)
# warning-ignore:unused_signal
signal tackling(trueOrFalse)
# warning-ignore:unused_signal
signal blocking(trueOrFalse)
# warning-ignore:unused_signal
signal outOfBounds()
# warning-ignore:unused_signal
signal knockout(player, team)
# warning-ignore:unused_signal
signal allKO(winningTeam)

var playerIndex = 0

#Array of the player controlled team
var playerTeam = []

#Array of the enemy team
var enemyTeam = []

#Array of all players
var allPlayers = []

func _ready():
	pause_mode = Node.PAUSE_MODE_STOP
	set_process(true)
# warning-ignore:return_value_discarded
	connect("inPossession", self, "possession_control")

func _process(_delta):
	if Input.is_action_just_pressed("ui_next_player"):
		next_player()
		
func next_player():
	playerTeam = get_tree().get_nodes_in_group("player_team")
	playerIndex += 1
	if playerIndex > playerTeam.size() - 1:
		playerIndex = 0
	emit_signal("controlling", playerTeam[playerIndex])	

func possession_control(player):
	if player in playerTeam:
		emit_signal("controlling", player)
