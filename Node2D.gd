extends Node2D


export var playerSelectMenu : NodePath


# Called when the node enters the scene tree for the first time.
func _ready():
	SceneController.playerTeam = get_tree().get_nodes_in_group("player_team")
	$SaveSystem.load_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
