extends Control

const GAME_SCENE_PATH = "res://node.tscn"
const GAME_MENU_PATH = "res://main_menu.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
	
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(GAME_MENU_PATH)
