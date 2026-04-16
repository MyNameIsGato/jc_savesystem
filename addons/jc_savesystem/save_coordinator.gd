class_name SaveCoordinator extends Node

static var save_path: String = "user://save.dat"
static var data: Dictionary[StringName, Variant]
static var fresh_id: int = NAN

static func save_game() -> bool:
	# If the data hasn't changed, skip the processing and report a succesful save.
	var id: int = data.hash()
	if id == fresh_id: return true
	var to_save: PackedByteArray = var_to_bytes_with_objects(data)
	if to_save.size() == 0: return false
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	var success: bool = file.store_buffer(to_save)
	if success: fresh_id = id
	return success

static func load_game() -> bool:
	var content: PackedByteArray = FileAccess.get_file_as_bytes(save_path)
	if content.size() == 0: return false
	data = bytes_to_var_with_objects(content)
	return true

static func set_data(key: StringName, value: Variant, override: bool = true) -> bool:
	if data.has(key) and !override: return false
	if !data: data = {}
	data[key] = value
	return true

static func get_data(key: StringName, default: Variant) -> Variant:
	if !data.has(key): return default
	return data[key]
