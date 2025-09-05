extends Control

onready var bgmusic = $Music/bgmusic
onready var click = $Music/clickingSound
onready var label = $Label

func _ready():
	bgmusic.play()
	$Music/winSound.play()
	$Music/did.play()

func _input(event):
	if event.is_action_pressed("ui_select") or (event is InputEventMouseButton and event.pressed):
		get_tree().set_input_as_handled()
	
		change_scene() 
	

func change_scene():
	click.play()
	FadeManager.fade_out()
	get_tree().change_scene("res://UI/TitleScreen.tscn")

