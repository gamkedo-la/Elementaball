extends Resource


class_name StartingStats

export var speciesName : String = "Species Name"
export var characterName : String = "Name"
export var type : String = "Type"
export var sprite : Texture

export var HP : int
export var maxHP : int
export var agility : int
export var power : int
export var speed : int
export var ability1 : Resource
export var ability2 : Resource
export var ability3 : Resource
export var ability4 : Resource

export(Array, Resource) var selectableAbilities

export var animStates : Resource
