extends Node

var abilityMenu1
var abilityMenu2
var abilityMenu3
var abilityMenu4
var abilityToLoad

var selectableAbilities

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_AbilityMenu1_initializeMenu(menu):
	abilityMenu1 = menu
	populate_menu(abilityMenu1, abilityToLoad)
	abilityMenu1.connect("item_selected",self,"ability1_item_selected")

func populate_menu(menu, abilityToLoad):
	menu.clear()
	if menu == abilityMenu1:
		abilityToLoad = get_parent().ability1
	elif menu == abilityMenu2:
		abilityToLoad = get_parent().ability2
	elif menu == abilityMenu3:
		abilityToLoad = get_parent().ability3
	elif menu == abilityMenu4:
		abilityToLoad = get_parent().ability4
	for ability in range(selectableAbilities.size()):
		menu.add_item(selectableAbilities[ability].name)
		if abilityToLoad:
			if abilityToLoad.name == selectableAbilities[ability].name: 
				menu.select(ability)

func populate_all_menus():
	var allMenus = [abilityMenu1, abilityMenu2, abilityMenu3, abilityMenu4]
	for menu in allMenus:
		if menu:
			populate_menu(menu, null)

func ability1_item_selected(index):
	get_parent().ability1 = selectableAbilities[index]
	
func ability2_item_selected(index):
	get_parent().ability2 = selectableAbilities[index]

func ability3_item_selected(index):
	get_parent().ability3 = selectableAbilities[index]
	
func ability4_item_selected(index):
	get_parent().ability4 = selectableAbilities[index]


func _on_AbilityMenu2_initializeMenu(menu):
	abilityMenu2 = menu
	populate_menu(abilityMenu2, abilityToLoad)
	abilityMenu2.connect("item_selected",self,"ability2_item_selected")


func _on_AbilityMenu3_initializeMenu(menu):
	abilityMenu3 = menu
	populate_menu(abilityMenu3, abilityToLoad)
	abilityMenu3.connect("item_selected",self,"ability3_item_selected")


func _on_AbilityMenu4_initializeMenu(menu):
	abilityMenu4 = menu
	populate_menu(abilityMenu4, abilityToLoad)
	abilityMenu4.connect("item_selected",self,"ability4_item_selected")
