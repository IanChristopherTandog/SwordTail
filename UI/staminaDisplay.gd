extends Control

onready var staminaBar = $TextureProgress 
onready var healthBar = $HealthBar
onready var expBar = $exp

func _ready():
	update_health()
	
	if PlayerStats.connect("expi_changed", self, "update_expi") != OK:
		print("Failed to connect expi_changed signal.")
#	if PlayerStats.connect("level_changed", self, "update_level")!= OK:
#		print("Failed to connect expi_changed signal.")
func _process(delta):
	update_health()
	

	
func update_stamina(value):
#	if staminaBar:
#		staminaBar.value = value
	if staminaBar:
		staminaBar.value = value
		
func update_health():
	healthBar.value = PlayerStats.health
	healthBar.max_value = PlayerStats.max_health
	
func update_expi(expi, max_expi):
	if expBar != null:
		expBar.value = float(expi) / max_expi * 100  
