extends Node2D

# warning-ignore:unused_signal
signal playSound(sound)
signal stopSound(sound)

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	# when _ready is called, there might already be nodes in the tree, so connect all existing buttons
	connect_buttons(get_tree().root)
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")
	SceneController.connect("knockout", self, "play_KO")
	SceneController.connect("outOfBounds", self, "short_whistle")
	
# warning-ignore:return_value_discarded
	connect("playSound", self, "play_sound")
	connect("stopSound", self, "stop_sound")
	play_sound("Menu Music")

func play_sound(sound):
	if has_node(sound):
		get_node(sound).play()
		
func stop_sound(sound):
	if has_node(sound):
		get_node(sound).stop()

func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)
		node.connect("mouse_entered", self, "_on_Button_focus_entered")
		node.connect("focus_entered", self, "_on_Button_focus_entered")
	if node is OptionButton:
		node.connect("item_focused", self, "_on_Button_focus_entered")
		node.connect("item_selected", self, "_on_Button_pressed")
	if node is PopupMenu:
		node.connect("id_focused", self, "_on_Button_focus_entered")
		node.connect("id_pressed", self, "_on_Button_pressed")		

func _on_Button_pressed(_index = 0):
	play_sound("Menu Select")
	
func _on_Button_focus_entered(_index = 0):
	play_sound("Menu Up-Down")

# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(button):
	button.connect("pressed", self, "_on_Button_pressed")
	
func play_KO(_player, _team):
	play_sound("KO")

func short_whistle():
	play_sound("Whistle")
