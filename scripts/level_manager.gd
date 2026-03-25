extends Control

@onready var level_list = $VBoxContainer/Level_List
@onready var level_name = $VBoxContainer/Level_Name

# Called when the node enters the scene tree for the first time.
func _ready():
	update_level_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

func _on_create_level_pressed():
	var raw_level_name = level_name.text
	var regex = RegEx.new()
	regex.compile("\\s")
	
	if !raw_level_name:
		level_name.text = ""
		level_name.placeholder_text = "Enter a name!"
		return
		
	if regex.search(raw_level_name):
		level_name.text = ""
		level_name.placeholder_text = "NO SPACES ALLOWED!"
		return

	var name_length = raw_level_name.length()
	if name_length < 3 or name_length > 16:
		level_name.text = ""
		level_name.placeholder_text = "3-16 CHARACTERS ONLY!"
		return

	var final_name = raw_level_name.validate_filename()
	var full_path = GlobalData.MAPS_DIR + final_name + ".json"
	
	if FileAccess.file_exists(full_path):
		level_name.text = ""
		level_name.placeholder_text = "LEVEL ALREADY EXISTS!"
		return

	GlobalData.current_level_name = final_name
	GlobalData.should_load_existing = false 
	GlobalData.level_size = Vector3(10,10,10)
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")


func _on_delete_level_pressed():
	var selected_items = level_list.get_selected_items()
	
	if selected_items.is_empty():
		print("Najpierw zaznacz level na liście!")
		return
		
	var index = selected_items[0]
	var file_to_delete = level_list.get_item_text(index)
	var full_path = GlobalData.MAPS_DIR + file_to_delete
	
	if FileAccess.file_exists(full_path):
		var err = DirAccess.remove_absolute(full_path)
		if err == OK:
			print("Usunięto plik: ", file_to_delete)
			update_level_list() 
		else:
			print("Błąd przy usuwaniu: ", err)


func _on_load_level_pressed():
	var selected_items = level_list.get_selected_items()
	
	if selected_items.is_empty():
		level_name.text = ""
		level_name.placeholder_text = "SELECT LEVEL FIRST!"
		return
		
	var index = selected_items[0]
	var file_to_load = level_list.get_item_text(index)
	
	GlobalData.current_level_name = file_to_load.get_basename()
	GlobalData.should_load_existing = true 
	
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")
