extends GdUnitTestSuite

# Constants for testing
const TEST_SAVE_PATH: String = "user://test_save.dat"
var original_save_path: String

func before_test() -> void:
	"""Set up before each test"""
	# Clear the save file and reset static variables
	original_save_path = SaveCoordinator.save_path
	SaveCoordinator.save_path = TEST_SAVE_PATH
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)
	SaveCoordinator.data.clear()
	SaveCoordinator.fresh_id = NAN

func after_test() -> void:
	"""Clean up after each test"""
	# Tidy up and return to original state
	SaveCoordinator.save_path = original_save_path
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)
	SaveCoordinator.data.clear()

func test_set_data_and_get_data() -> void:
	"""Test setting and retrieving data"""
	var key: StringName = &"player_health"
	var value: int = 100
	var result: bool = SaveCoordinator.set_data(key, value)
	assert_that(result).is_true()
	
	# Verify data was set
	var retrieved: int = SaveCoordinator.get_data(key, 0)
	assert_that(retrieved).is_equal(value)
	
	# Test getting data with default value
	var default: int = 50
	var non_existent: int = SaveCoordinator.get_data(&"nonexistent", default)
	assert_that(non_existent).is_equal(default)
	
	# Test that data is stored in the dictionary
	assert_that(SaveCoordinator.data.has(key)).is_true()
	assert_that(SaveCoordinator.data[key]).is_equal(value)

func test_set_data_prevents_overwrite() -> void:
	"""Test that set_data returns false when key already exists"""
	# Set initial data
	var key: StringName = &"player_name"
	var initial_value: String = "Tim"
	SaveCoordinator.set_data(key, initial_value)
	
	# Try to set same key again
	var new_value: String = "Bob"
	var result: bool = SaveCoordinator.set_data(key, new_value, false)
	assert_that(result).is_false()
	
	# Verify original value remains
	var retrieved: String = SaveCoordinator.get_data(key, "")
	assert_that(retrieved).is_equal(initial_value)

func test_save_and_load_basic_types() -> void:
	"""Test saving and loading basic data types"""
	# Set up test data with various basic types
	SaveCoordinator.set_data(&"int_value", 42)
	SaveCoordinator.set_data(&"float_value", 3.14159)
	SaveCoordinator.set_data(&"string_value", "Hello World")
	SaveCoordinator.set_data(&"bool_true", true)
	SaveCoordinator.set_data(&"bool_false", false)
	
	# Save the data
	var save_result: bool = SaveCoordinator.save_game()
	assert_that(save_result).is_true()
	
	# Verify file was created
	assert_that(FileAccess.file_exists(TEST_SAVE_PATH)).is_true()
	
	# Clear current data to simulate fresh start
	SaveCoordinator.data.clear()
	assert_that(SaveCoordinator.data).is_empty()
	
	# Load the data
	var load_result: bool = SaveCoordinator.load_game()
	assert_that(load_result).is_true()
	
	# Verify loaded data
	assert_that(SaveCoordinator.get_data(&"int_value", 0)).is_equal(42)
	assert_that(SaveCoordinator.get_data(&"float_value", 0.0)).is_equal(3.14159)
	assert_that(SaveCoordinator.get_data(&"string_value", "")).is_equal("Hello World")
	assert_that(SaveCoordinator.get_data(&"bool_true", false)).is_true()
	assert_that(SaveCoordinator.get_data(&"bool_false", true)).is_false()

func test_save_and_load_complex_types() -> void:
	"""Test saving and loading complex data types"""
	var array_value: Array = [1, 2, 3, "test", true]
	SaveCoordinator.set_data(&"array_value", array_value)
	var dict_value: Dictionary = {"key1": "value1", "key2": 42, "key3": false}
	SaveCoordinator.set_data(&"dict_value", dict_value)
	
	SaveCoordinator.set_data(&"vector2", Vector2(10.5, 20.3))
	SaveCoordinator.set_data(&"vector3", Vector3(1, 2, 3))
	SaveCoordinator.set_data(&"color", Color(0.5, 0.2, 0.8, 1.0))
	
	var save_result: bool = SaveCoordinator.save_game()
	assert_that(save_result).is_true()
	
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	
	# Verify
	assert_that(SaveCoordinator.get_data(&"array_value", [])).is_equal(array_value)
	assert_that(SaveCoordinator.get_data(&"dict_value", {})).is_equal(dict_value)
	assert_that(SaveCoordinator.get_data(&"vector2", Vector2())).is_equal(Vector2(10.5, 20.3))
	assert_that(SaveCoordinator.get_data(&"vector3", Vector3())).is_equal(Vector3(1, 2, 3))
	assert_that(SaveCoordinator.get_data(&"color", Color())).is_equal(Color(0.5, 0.2, 0.8, 1.0))

func test_nested_structures() -> void:
	"""Test saving and loading nested data structures"""
	var nested: Dictionary = {
		"player": {
			"name": "Tim",
			"stats": {
				"health": 100,
				"mana": 50,
				"position": Vector3(10, 0, 20)
			},
			"inventory": ["sword", "shield", "potion"]
		}
	}
	
	SaveCoordinator.set_data(&"nested_data", nested)
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	
	var loaded: Dictionary = SaveCoordinator.get_data(&"nested_data", {})
	assert_that(loaded).has_size(1)
	assert_that(loaded["player"]["name"]).is_equal("Tim")
	assert_that(loaded["player"]["stats"]["health"]).is_equal(100)
	assert_that(loaded["player"]["inventory"][0]).is_equal("sword")

func test_load_fails_with_invalid_file() -> void:
	"""Test that load_game returns false when no save file exists"""
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)
	
	var result: bool = SaveCoordinator.load_game()
	assert_that(result).is_false()
	assert_that(SaveCoordinator.data).is_empty()

func test_save_and_load_multiple_keys() -> void:
	"""Test saving and loading multiple keys"""
	var keys: Array[String] = ["key1", "key2", "key3", "key4", "key5"]
	var values: Array[int] = [10, 20, 30, 40, 50]
	
	for i in keys.size():
		SaveCoordinator.set_data(keys[i], values[i])
	
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	
	for i in keys.size():
		assert_that(SaveCoordinator.get_data(keys[i], 0)).is_equal(values[i])
	assert_that(SaveCoordinator.data).has_size(keys.size())

func test_fresh_id_updates_on_save() -> void:
	"""Test that fresh_id updates when save is successful"""
	SaveCoordinator.set_data(&"test", 100)
	var initial_id: int = SaveCoordinator.fresh_id
	
	SaveCoordinator.save_game()
	assert_that(SaveCoordinator.fresh_id).is_not_equal(initial_id)

func test_edge_cases() -> void:
	"""Test encountered edge cases"""
	# Empty data save
	var empty_save: bool = SaveCoordinator.save_game()
	assert_that(empty_save).is_true()
	
	# Empty string value
	SaveCoordinator.set_data(&"empty_string", "")
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	assert_that(SaveCoordinator.get_data(&"empty_string", "default")).is_equal("")
	
	# Very large array
	var large_array: Array = []
	for i in range(1000):
		large_array.append(i)
	SaveCoordinator.set_data(&"large_array", large_array)
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	assert_that(SaveCoordinator.get_data(&"large_array", [])).has_size(1000)
	
	# Null value
	SaveCoordinator.set_data(&"null_value", null)
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	var null_retrieved: Variant = SaveCoordinator.get_data(&"null_value", "not_null")
	assert_that(null_retrieved).is_null()

func test_data_persistence_between_sessions() -> void:
	"""Test data persistence across multiple save/load cycles"""
	# First save cycle
	SaveCoordinator.set_data(&"persistent_value", 42)
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	assert_that(SaveCoordinator.get_data(&"persistent_value", 0)).is_equal(42)
	
	# Modify and save again
	SaveCoordinator.set_data(&"persistent_value", 99, true)
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	assert_that(SaveCoordinator.get_data(&"persistent_value", 0)).is_equal(99)
	
	# Add new data in second session
	SaveCoordinator.set_data(&"new_value", "added later")
	SaveCoordinator.save_game()
	SaveCoordinator.data.clear()
	SaveCoordinator.load_game()
	assert_that(SaveCoordinator.get_data(&"persistent_value", 0)).is_equal(99)
	assert_that(SaveCoordinator.get_data(&"new_value", "")).is_equal("added later")
