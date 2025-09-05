extends Control


onready var bgmusic = $Music/bgmusic
onready var click = $Music/clickingSound
onready var label = $Note

var tween: Tween

export (bool) var can_toggle_pause: bool = true

func _ready():
	bgmusic.play()
	create_tween()

	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:			
			resume()
func pause():
	get_tree().set_deferred("paused", true)
	print("paused")
	
func resume():
	get_tree().set_deferred("paused", false)
	click.play()
	self.hide()
	print("resumed")
	
func create_tween():
	if tween:  
		tween.queue_free()
	
	tween = Tween.new()
	add_child(tween)

	tween.interpolate_property(label, "modulate:a", 1.0, 0.3, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(label, "modulate:a", 0.3, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0)

	tween.start()
	if tween.connect("tween_all_completed", self, "create_tween")!= OK:
		print("Failed to connect tween_all_completed.")
