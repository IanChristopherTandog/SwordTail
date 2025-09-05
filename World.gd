extends Node2D

var tween  
onready var pause_menu = $Pause/PauseScene
onready var statstab = $tab/Buffs
onready var map = $Map

func _ready():
	tween = Tween.new()
	add_child(tween)

	modulate.a = 0.0  
	create_fade_in()
	
	pause_menu.hide()
	statstab.hide()

func create_fade_in():
	tween.interpolate_property(self, "modulate:a", 0.0, 1.0, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func create_fade_out():
	get_tree().paused = true  

	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(get_tree().create_timer(1.5), "timeout")  
	get_tree().reload_current_scene()  

func check_player_health():
	if PlayerStats.health <= 0:
		create_fade_out()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !get_tree().paused and !statstab.visible:
			pause()
	if Input.is_action_just_pressed("tab"):
		if !get_tree().paused and !pause_menu.visible:
			show_statstab()
		
func _input(event):
	if Input.is_action_just_pressed("map"):
		map.visible = !map.visible
func pause():
	get_tree().set_deferred("paused", true)
	pause_menu.show()
	print("paused 2")

func show_statstab():
	if statstab.visible:
		statstab.hide()
	else:
		statstab.show()
	print("stats")

	
