extends CanvasLayer

@onready var item_list = $Control2/Object_List # Upewnij się, że ścieżka jest poprawna
# Called when the node enters the scene tree for the first time.
func _ready():
	fill_item_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func fill_item_list():
	item_list.clear()
	
	# Ścieżka do folderu, w którym trzymasz sceny obiektów
	var path = "res://scenes/objects/" 
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Filtrujemy tylko pliki scen .tscn
			if !dir.current_is_dir() and file_name.ends_with(".tscn"):
				# Dodajemy nazwę do listy (usuwamy końcówkę .tscn dla estetyki)
				var clean_name = file_name.replace(".tscn", "")
				item_list.add_item(clean_name)
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Błąd: Nie można otworzyć folderu: ", path)
