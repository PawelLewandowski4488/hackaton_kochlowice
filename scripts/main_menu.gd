extends Control

const GAME_SCENE_PATH = "res://scenes/game.tscn" 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
