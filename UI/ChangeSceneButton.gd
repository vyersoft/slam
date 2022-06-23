tool # run any code inside of the editor
extends Button

export(String, FILE) var next_scene_path: = ""

func _on_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene(next_scene_path)
	

func _get_configuration_warning() -> String:
	return "The next scene property can't be empty" if next_scene_path=="" else ""
