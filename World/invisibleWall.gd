extends StaticBody2D

onready var message = $note
onready var message_timer = $MessageTimer
onready var hurtbox = $Hurtbox
onready var wall = $Wall
onready var wallbar = $wallBar 

var RequiredLevel: int = 3
var wall_hp = 100 
var max_wall_hp = 100  

signal wall_hp_changed(value, max_value)  

func set_wall_hp(value):
	wall_hp = clamp(value, 0, max_wall_hp) 
	emit_signal("wall_hp_changed", wall_hp, max_wall_hp)

func _ready():
	message.visible = false
	wallbar.value = Global.wall_hp  

func _on_Hurtbox_area_entered(area):
	if PlayerStats.level >= RequiredLevel: 
		wallbar.visible = true
		Global.wall_hp -= 20
		wallbar.value = max(Global.wall_hp, 0)  
		
		print("Wall HP after hit:", Global.wall_hp)   
		
		if Global.wall_hp >= 40:
			blink_effect()
		elif Global.wall_hp <= 0:
			queue_free() 
	else:
		wallbar.visible = false
		message.visible = true
		message_timer.start()
 

func _on_MessageTimer_timeout():
	message.visible = false  

func blink_effect():
	for i in range(4):  
		wall.visible = false
		yield(get_tree().create_timer(0.1), "timeout")  
		wall.visible = true
		yield(get_tree().create_timer(0.1), "timeout")  
