extends ColorRect

export var segment_size := 1  # Each segment represents 1 health point

func _ready():
	PlayerStats.connect("max_health_changed", self, "update_divisions")
	update_divisions()

func update_divisions():
	update()  # Force redraw

func _draw():
	if segment_size <= 0 or PlayerStats.max_health <= 0:
		return  # Prevent division by zero

	var divisions = PlayerStats.max_health  # Number of health points
	var segment_width = rect_size.x / float(divisions)  # Spacing

	for i in range(1, divisions):  # Start from 1 to avoid first position
		var x_pos = i * segment_width
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, rect_size.y), Color(1, 1, 1), 2)  # White lines
