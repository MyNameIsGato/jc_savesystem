class_name SaveCoordinator extends Node

static var save_path: String = "user://save.dat"
static var data: Dictionary[StringName, Variant]
static var _dirty: Dictionary[StringName, bool]
static var fresh_id: int = NAN
static var _loaded: bool = false

static func save_game() -> bool:
	# If the data hasn't changed, skip the processing and report a succesful save.
	var id: int = data.hash()
	if id == fresh_id: return true
	var to_save: PackedByteArray = var_to_bytes_with_objects(data)
	if to_save.size() == 0: return false
	_loaded = true
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	var success: bool = file.store_buffer(to_save)
	if success: fresh_id = id
	for i: StringName in _dirty:
		_dirty[i] = false
	return success

static func load_game() -> bool:
	_loaded = true
	var content: PackedByteArray = FileAccess.get_file_as_bytes(save_path)
	if content.size() == 0: return false
	data = bytes_to_var_with_objects(content)
	return true

static func set_data(key: StringName, value: Variant, override: bool = true) -> bool:
	if data.has(key) and !override: return false
	if !data: data = {}
	data[key] = value
	_dirty[key] = true
	return true

static func get_data(key: StringName, default: Variant) -> Variant:
	if !data.has(key): return default
	return data[key]

static func reset() -> void:
	data.clear()
	_dirty.clear()
	_loaded = false
	
static func change_path(path: String) -> bool:
	if path.length() == 0: return false
	save_path = path
	_loaded = false
	return true

static func is_dirty() -> bool:
	for i: StringName in _dirty:
		if _dirty[i] == true: return true
	return false

static func save_exists() -> bool:
	return _loaded and !data.is_empty()
