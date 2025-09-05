extends StaticBody2D 

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var healthBar = $TextureProgress

func _ready():
	healthBar.value = stats.health

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	healthBar.value = stats.health
	print(stats.health)
	
func _on_Stats_no_health():
	PlayerStats.add_expi(100) 
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
	FadeManager.fade_out()
	get_tree().change_scene("res://UI/EndScreen.tscn")
