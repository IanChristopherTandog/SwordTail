extends Node

export var max_health = 1 setget set_max_health
export var max_expi = 100  # EXP required to level up
export var level = 1  # Player level

var health = max_health setget set_health
var expi = 0  # Current experience points

#onready var deathSounds = $deathSounds

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
#		deathSounds.play()

func add_expi(amount):
	expi += amount
	if expi >= max_expi:
		level_up()
	emit_signal("expi_changed", expi, max_expi)

func level_up():
	expi -= max_expi  # Carry over extra EXP
	level += 1
	max_expi += 20  # Increase EXP requirement per level
	emit_signal("level_changed", level)
	emit_signal("expi_changed", expi, max_expi)

func _ready():
	self.health = max_health
	emit_signal("expi_changed", expi, max_expi)
	emit_signal("level_changed", level)
