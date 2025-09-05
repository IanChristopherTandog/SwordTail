extends Node

export var max_health = 10 setget set_max_health
export var max_expi = 100  # EXP required to level up
export var level = 1  # Player level

var health = max_health setget set_health
var expi = 0  # Current experience points
var regenLevel = 6

onready var deathSounds = $deathSounds

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal expi_changed(value, max_expi)
signal level_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		deathSounds.play()

		get_tree().change_scene("res://UI/TitleScreen.tscn")
	
func add_expi(amount):
	expi += amount
	if expi >= max_expi:
		level_up()
	emit_signal("expi_changed", expi, max_expi)

func add_hp(amount):
	if health < max_health: 
#		var prev_hp = health
		set_health(health + amount)  
		
#		if health > prev_hp:  
#			get_tree().get_root().find_node("Player", true, false).healEffects()
	get_tree().get_root().find_node("Player", true, false).healEffects()


func level_up():
	expi -= max_expi  # Carry over extra EXP
	level += 1
	max_expi += 20  # Increase EXP requirement per level
	emit_signal("level_changed", level)
	emit_signal("expi_changed", expi, max_expi)
	
	increase_hp()
	lifesteal()
	

func increase_hp():
	if level == 3:
		set_max_health(max_health + 1)  # Increase max health
		set_health(health + 1)  # Heal the player by 1
	elif level == 4:
		set_max_health(max_health + 1)  
		set_health(health + 1)
	elif level == 5:
		set_max_health(max_health + 1)  
		set_health(health + 1)
		
func lifesteal():
	if level >= 2:
		add_hp(1)
		
func hp_regeneration():
	if health <= max_health:
		if level >= regenLevel:
			add_hp(1)
		elif level >= regenLevel + 4:
			add_hp(2)
	
func reset():
	level = 1
	expi = 0
	max_health = 10
	health = max_health
	emit_signal("level_changed", level)
	emit_signal("expi_changed", expi, max_expi)
	emit_signal("health_changed", health)

func _ready():
	self.health = max_health
	emit_signal("expi_changed", expi, max_expi)
	emit_signal("level_changed", level)

