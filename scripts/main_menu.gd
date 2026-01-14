extends Control

const GAME_SCENE_PATH = "res://scenes/game.tscn" 
const LEVEL_EDITOR_SCENE_PATH = "res://scenes/level_editor.tscn"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _on_level_editor_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_EDITOR_SCENE_PATH)
