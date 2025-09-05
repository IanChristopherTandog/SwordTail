extends Control

onready var bgmusic = $Music/bgmusic
onready var click = $Music/clickingSound
onready var label = $Label

var tween: Tween

func _ready():
	bgmusic.play()
	create_tween()
	PlayerStats.health = 4
	
func _input(event):
	if event.is_action_pressed("ui_select") or (event is InputEventMouseButton and event.pressed):
		PlayerStats.reset()
		print(PlayerStats.health)
		get_tree().set_input_as_handled()
	
		change_scene()

func start_fade_out():
	var fade_tween = Tween.new()
	add_child(fade_tween)

	fade_tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	fade_tween.start()

	# Use a timer instead of `yield()`
	var timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	timer.start()

	timer.connect("timeout", self, "change_scene")

func change_scene():
	click.play()
	FadeManager.fade_out()
	get_tree().change_scene("res://World.tscn")

func create_tween():
	if tween:  
		tween.queue_free()
	
	tween = Tween.new()
	add_child(tween)

	tween.interpolate_property(label, "modulate:a", 1.0, 0.3, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(label, "modulate:a", 0.3, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0)

	tween.start()
	if tween.connect("tween_all_completed", self, "create_tween") != OK:
		print("tween did not work")
		#tried debug
