extends Control

onready var click = $clickingSound
onready var label = $Label
var tween: Tween  
var is_transitioning = false  

func _ready():
	create_tween()

func _input(event):
	if is_transitioning: 
		return

	if event.is_action_pressed("ui_select"):
		is_transitioning = true
		click.play()
		start_fade_out("change_scene")  

	elif event.is_action_pressed("Exit"):
		is_transitioning = true
		click.play()
		start_fade_out("quit_game")  

func start_fade_out(method_name):
	var fade_tween = Tween.new()
	add_child(fade_tween)

	fade_tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	fade_tween.start()


	var timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	timer.start()

	timer.connect("timeout", self, method_name)  

func change_scene():
	Global.next_level()

func quit_game():
	get_tree().quit()

func create_tween():
	if tween:  
		tween.queue_free()
	
	tween = Tween.new()
	add_child(tween)

	tween.interpolate_property(label, "modulate:a", 1.0, 0.3, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(label, "modulate:a", 0.3, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0)

	tween.start()
	tween.connect("tween_all_completed", self, "create_tween")
