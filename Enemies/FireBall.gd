extends KinematicBody2D

export var speed = 1.5  
export var damage = 10
export var curve_height = 30  # How high the fireball arcs before descending

var start_position = Vector2.ZERO
var target_position = Vector2.ZERO
var progress = 0.0  # Keeps track of the fireball's movement progression

onready var animated_sprite = $fireAnimated
onready var collision_shape = $CollisionShape2D

func _ready():
	animated_sprite.play("default")  
	

func _physics_process(delta):
	if progress < 1.0:
		progress += delta * speed  # Adjust speed factor for smoothness
		var new_position = calculate_curve(start_position, target_position, curve_height, progress)
		
		# Rotate fireball to face movement direction
		var direction = new_position - global_position
		if direction.length() > 0:  # Prevent division by zero
			rotation = direction.angle()  

		global_position = new_position
	else:
		animated_sprite.play("Explode")
		yield(animated_sprite, "animation_finished")
		queue_free()


func launch(start_pos, target_pos):
	start_position = start_pos
	target_position = target_pos
	global_position = start_pos

func calculate_curve(start, end, height, t):
	# Quadratic Bezier Curve formula for an arc
	var mid = (start + end) / 2 + Vector2(0, -height)  # Control point for the arc
	return (1 - t) * (1 - t) * start + 2 * (1 - t) * t * mid + t * t * end
