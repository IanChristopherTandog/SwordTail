extends Node2D

export (PackedScene) var enemy_scene  # Enemy scene to spawn
export var max_enemies := 5           # Maximum number of enemies allowed
export var spawn_interval := 5.0      # Time between spawns

var enemies := []  # Track spawned enemies

func _ready():
	print("Spawner ready! Waiting", spawn_interval, "seconds before spawning...")
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _on_Timer_timeout():
	print("Spawn timer triggered. Current enemy count:", enemies.size())
	
	if enemies.size() < max_enemies:
		print("Spawning a new enemy...")
		spawn_enemy()
	else:
		print("Max enemies reached! No spawn.")

func spawn_enemy():
	if enemy_scene == null:
		print("ERROR: enemy_scene is not assigned!")
		return

	var spawn_position = get_spawn_position()
	if spawn_position == null:
		print("ERROR: No valid spawn points!")
		return

	var enemy = enemy_scene.instance()
	enemy.global_position = spawn_position
	add_child(enemy)
	enemies.append(enemy)

	print("Enemy spawned at:", spawn_position)

func get_spawn_position():
	var spawn_points = []
	
	for child in get_children():
		if child is Position2D:
			spawn_points.append(child)
	
	if spawn_points.size() > 0:
		var chosen_spawn = spawn_points[randi() % spawn_points.size()]
		print("Chosen spawn point:", chosen_spawn.name, "at", chosen_spawn.global_position)
		return chosen_spawn.global_position
	
	print("No spawn points found!")
	return null
