extends Control

@onready var level_list = $VBoxContainer/Level_List
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_level_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func update_level_list():
	level_list.clear()
	
	var path = GlobalData.MAPS_DIR
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".json"):
				level_list.add_item(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Błąd: Nie można uzyskać dostępu do folderu maps.")

func _on_load_level_pressed() -> void:
	var selected_items = level_list.get_selected_items()
	
	if selected_items.is_empty():
		return
		
	var index = selected_items[0]
	var file_to_load = level_list.get_item_text(index)
	
	GlobalData.current_level_name = file_to_load.get_basename()
	
	get_tree().change_scene_to_file("res://scenes/game_2.tscn")
