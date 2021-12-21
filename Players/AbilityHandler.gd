extends Node

var abilityMenu1
var abilityMenu2
var abilityMenu3
var abilityMenu4

var selectableAbilities

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_AbilityMenu1_initializeMenu(menu):
	abilityMenu1 = menu
	populate_menu(abilityMenu1)
	abilityMenu1.connect("item_selected",self,"ability1_item_selected")

func populate_menu(menu):
	menu.clear()
	menu.add_item("Select Ability")
	for ability in selectableAbilities:
		menu.add_item(ability.name)

func populate_all_menus():
	var allMenus = [abilityMenu1, abilityMenu2, abilityMenu3, abilityMenu4]
	for menu in allMenus:
		if menu:
			populate_menu(menu)

func ability1_item_selected(index):
	get_parent().ability1 = selectableAbilities[index-1]
	
func ability2_item_selected(index):
	get_parent().ability2 = selectableAbilities[index-1]

func ability3_item_selected(index):
	get_parent().ability3 = selectableAbilities[index-1]
	
func ability4_item_selected(index):
	get_parent().ability4 = selectableAbilities[index-1]


func _on_AbilityMenu2_initializeMenu(menu):
	abilityMenu2 = menu
	populate_menu(abilityMenu2)
	abilityMenu2.connect("item_selected",self,"ability2_item_selected")


func _on_AbilityMenu3_initializeMenu(menu):
	abilityMenu3 = menu
	populate_menu(abilityMenu3)
	abilityMenu3.connect("item_selected",self,"ability3_item_selected")


func _on_AbilityMenu4_initializeMenu(menu):
	abilityMenu4 = menu
	populate_menu(abilityMenu4)
	abilityMenu4.connect("item_selected",self,"ability4_item_selected")
