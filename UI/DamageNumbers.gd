extends Position2D


onready var label = $Label
onready var tween = $Tween

var amount = 1

var velocity = Vector2(0,5)

func _ready():
	label.set_text(str(-amount))
	
	tween.interpolate_property(self, "scale", scale, Vector2(1.5,1.5), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", Vector2(1.5,1.5), Vector2(.1,.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _process(delta):
	position -= velocity * delta

func _on_Tween_tween_all_completed():
	self.queue_free()
