extends Node

var wall_hp = 100 
var max_wall_hp = 100  

signal wall_hp_changed(value, max_value)  

func set_wall_hp(value):
	wall_hp = clamp(value, 0, max_wall_hp) 
	emit_signal("wall_hp_changed", wall_hp, max_wall_hp)
