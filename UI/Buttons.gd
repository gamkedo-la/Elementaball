extends HBoxContainer

export var buttonName : String
signal change(direction)


func _ready():
	$Label.text = buttonName


func _on_Minus_pressed():
	emit_signal("change", -1)


func _on_Plus_pressed():
	emit_signal("change", 1)
