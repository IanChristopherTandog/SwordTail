extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var levelLabel = $levelCount  
onready var expBar = $expBar  
onready var hpRegenTimer = $hpRegenTimer
onready var hpRegenDisplay = $newUI/hpRegen  # 
func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_min_size.x = hearts * 15

	check_hp_regen()

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_min_size.x = max_hearts * 15

func update_expi(expi, max_expi):
	if expBar != null:
		expBar.value = float(expi) / max_expi * 100  

func update_level(level):
	if levelLabel != null:
		levelLabel.text = str(level) 

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	
	# Connect signals for health changes
	if PlayerStats.connect("health_changed", self, "set_hearts") != OK:
		print("Failed to connect health_changed signal.")
	if PlayerStats.connect("max_health_changed", self, "set_max_hearts") != OK:
		print("Failed to connect max_health_changed signal.")
	if PlayerStats.connect("expi_changed", self, "update_expi") != OK:
		print("Failed to connect expi_changed signal.")
	if PlayerStats.connect("level_changed", self, "update_level")!= OK:
		print("Failed to connect level_changed signal.")

	# Initialize progress bar settings
	hpRegenDisplay.max_value = hpRegenTimer.wait_time
	hpRegenDisplay.value = 0

func check_hp_regen():
	# If HP is not full, start the timer
	if PlayerStats.level >= PlayerStats.regenLevel:
		if PlayerStats.health < PlayerStats.max_health and hpRegenTimer.is_stopped():
			hpRegenTimer.start()
			print("HP Regen Timer Started.")
		elif PlayerStats.health >= PlayerStats.max_health:
			hpRegenTimer.stop()
			hpRegenDisplay.value = 0  

func _process(delta):
	
	if not hpRegenTimer.is_stopped():
		hpRegenDisplay.value = hpRegenTimer.time_left

func _on_hpRegenTimer_timeout():
	print("Current HP:", PlayerStats.health)
	PlayerStats.hp_regeneration()
	check_hp_regen() 
