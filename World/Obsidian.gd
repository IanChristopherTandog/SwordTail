extends StaticBody2D

onready var message = $note
onready var message_timer = $MessageTimer
onready var hurtbox = $Hurtbox
onready var wall = $Obsidian
onready var wallbar = $wallBar 
onready var stats = $Stats

var RequiredLevel: int = 6
var is_blinking = false  

func _ready():
	message.visible = false
	wallbar.value = stats.health  # ✅ Ensure progress bar starts with correct HP
	wallbar.max_value = stats.max_health

func _on_PlayerDetector_body_entered(body):
	if PlayerStats.level >= RequiredLevel:
		wall.visible = false
	else:
		message.visible = true
		message_timer.start()  

func _on_Hurtbox_area_entered(area):

	stats.health -= area.damage

	if PlayerStats.level >= RequiredLevel:
		
		wallbar.visible = true
		wallbar.value = stats.health
		if stats.health >= 2:
			blink_effect()
		elif stats.health <= 0:
			queue_free() 
	else:
		# Player does not meet level requirement, show warning
		wallbar.visible = false
		message.visible = true
		message_timer.start()
 

func _on_MessageTimer_timeout():
	message.visible = false  

func blink_effect():
	if is_blinking:
		return  

	is_blinking = true
	
	for i in range(4):  
		wall.visible = false
		yield(get_tree().create_timer(0.1), "timeout")  
		wall.visible = true
		yield(get_tree().create_timer(0.1), "timeout")  
	
	is_blinking = false  
