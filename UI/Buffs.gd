extends Control

onready var level = $labels/level
onready var expBar = $TextureProgress
onready var health = $labels/health
onready var attack = $labels/attack
onready var speed = $labels/speed
onready var iceMessage = $Quest/ice
onready var fireMessage = $Quest/fire

func _ready():
	if PlayerStats:
		if PlayerStats.connect("level_changed", self, "_on_level_changed") != OK:
			print("Failed to connect level_changed signal.")
		if PlayerStats.connect("expi_changed", self, "_on_expi_changed") != OK:
			print("Failed to connect expi_changed signal.")
		if PlayerStats.connect("health_changed", self, "_on_health_changed") != OK:
			print("Failed to connect health_changed signal.")
		if PlayerStats.connect("max_health_changed", self, "_on_max_health_changed") != OK:
			print("Failed to connect max_health_changed signal.")
		if PlayerStats.connect("no_health", self, "_on_no_health") != OK:
			print("Failed to connect no_health signal.")

		# **Manually update the UI with the initial values**
		_on_health_changed(PlayerStats.health)
		_on_expi_changed(PlayerStats.expi, PlayerStats.max_expi)
		_on_level_changed(PlayerStats.level)

	else:
		print("PlayerStats is null! Check your autoload settings.")
		return  # Exit function early if PlayerStats is not available

func _on_level_changed(new_level):
	level.text = "Lvl: " + str(new_level)
	  # Only update UI when level changes

func _on_expi_changed(current_expi, max_expi):
#	expBar.value = float(current_expi) / float(max_expi) * 100 if max_expi > 0 else 0
	expBar.value = current_expi/max_expi * 100 if max_expi > 0 else 0
	messageVisible()

func _on_health_changed(current_health):
	health.text = "HP: " + str(current_health) + "/" + str(PlayerStats.max_health)

func _on_max_health_changed(new_max_health):
	_on_health_changed(PlayerStats.health)  # Ensure UI updates when max HP changes

func _on_no_health():
	PlayerStats.expi = 0  # Reset exp to 0
	_on_expi_changed(0, PlayerStats.max_expi) 
	Global.wall_hp = 100

func messageVisible():
	# Hide all first
	iceMessage.visible = false
	fireMessage.visible = false
	$Quest/general.visible = false

	# Show correct message
	if PlayerStats.level <= 2:
		iceMessage.visible = true
	elif PlayerStats.level == 3:
		iceMessage.visible = true
		iceMessage.text = "Destroy the  Icebound Rift!"
	elif PlayerStats.level >= 4 and PlayerStats.level <= 5:
		fireMessage.visible = true
	elif PlayerStats.level == 6:
		fireMessage.visible = true
		fireMessage.text = "Destroy the Obsidian Riftwall!"
	else:
		$Quest/general.visible = true

