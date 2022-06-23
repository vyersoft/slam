extends Control

var master_bus = AudioServer.get_bus_index("Master")
var effect_bus = AudioServer.get_bus_index("effect")
var effect2_bus = AudioServer.get_bus_index("effect2")


var pop_up = preload('res://pop_up.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var splash = pop_up.instance()
	add_child(splash)

func _on_VSlider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	AudioServer.set_bus_volume_db(effect_bus, value)
	AudioServer.set_bus_volume_db(effect2_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
		AudioServer.set_bus_mute(effect_bus, true)
		AudioServer.set_bus_mute(effect2_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
		AudioServer.set_bus_mute(effect_bus, false)
		AudioServer.set_bus_mute(effect2_bus, false)
