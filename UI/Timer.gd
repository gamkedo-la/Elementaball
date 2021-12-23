extends RichTextLabel

signal gameOver(winOrLose)

var timer
var t = 180
var time
var scoreBoard

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreBoard = get_node("../..")
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer) #to process
	timer.set_wait_time(t)
	
func _process(_delta):
	_calc_minutes()
	self.text = "Time Left " + time
	
	if Input.is_action_pressed("time_hack"):
		timer.stop()
		timer.set_wait_time(5)
		timer.start()
		
func _on_timer_timeout():
	if scoreBoard.blueScore > scoreBoard.redScore:
		emit_signal("gameOver", "win")
	elif scoreBoard.blueScore < scoreBoard.redScore:
		emit_signal("gameOver", "lose")
	else:
		emit_signal("gameOver", "draw")
		
func _calc_minutes():
	t = timer.get_time_left()
	# assuming t has the miliseconds measured value
	var minutes = int(t / 60)
	var seconds = int(t) % 60

	time = ("%01d" % minutes) + (":%02d" % seconds)


func _on_StartButton_pressed():
	timer.start()
