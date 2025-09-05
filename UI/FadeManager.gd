extends CanvasLayer 

onready var color_rect = $ColorRect
onready var animationPlayer = $AnimationPlayer

func _ready():
	color_rect.hide()
func fade_out(duration = 1.0):
	color_rect.show()
	animationPlayer.play("fadeOut")

func fade_in(duration = 1.0):
	animationPlayer.play("fadeIn")
