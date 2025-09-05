extends Control

export var map_size := Vector2(200,200) 
export var world_size := Vector2(800,800)

var enemy_dots = {}  
var player = null  


func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _process(delta):
	update_enemy_positions()
	update_minimap()

func update_enemy_positions():
	var enemies = get_tree().get_nodes_in_group("Enemies")

	# Remove dots for enemies that no longer exist
	for enemy in enemy_dots.keys():
		if not is_instance_valid(enemy) or not enemies.has(enemy):  
			enemy_dots[enemy].queue_free()  
			enemy_dots.erase(enemy)  

	for enemy in enemies:
		if not enemy_dots.has(enemy):
			var dot = Sprite.new()
			dot.texture = load("res://UI/EnemyMini.png") 
			dot.scale = Vector2(0.2, 0.2) 
			dot.modulate = Color(1, 0.5, 0.5) 

			if $EnemyDots:  
				$EnemyDots.add_child(dot)
				enemy_dots[enemy] = dot  

		# Update dot position
		if enemy in enemy_dots:
			var mini_pos = (enemy.global_position / world_size) * map_size
			enemy_dots[enemy].position = mini_pos 
  

func update_minimap():
	if player and $PlayerDot:
		
		$PlayerDot.position = map_size / 2 
		var angle = player.velocity.angle()
		$PlayerDot.rotation = angle + PI / 2
		for enemy in enemy_dots.keys():
			if enemy and enemy_dots[enemy]:
				var relative_pos = (enemy.global_position - player.global_position) / world_size * map_size
				
				relative_pos.x = clamp(relative_pos.x, -map_size.x / 2, map_size.x / 2)
				relative_pos.y = clamp(relative_pos.y, -map_size.y / 2, map_size.y / 2)
				
				enemy_dots[enemy].position = (map_size / 2) + relative_pos
