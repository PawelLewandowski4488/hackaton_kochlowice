extends Node

var current_level_name: String = ""
var should_load_existing : bool = false
var level_size: Vector3i = Vector3i(10,10,10)

const MAPS_DIR = "user://maps/"
const OBJ_DIR = "res://scenes/objects/"
