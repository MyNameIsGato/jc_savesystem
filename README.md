# JC SaveSystem

<p align="center">
  <img alt="Jupiter Coast Logo" src="JupiterCoastHalf.png" />
</p>

_JC SaveSystem_ is an add-on for Godot 4.4+ which provides a utility class singleton that handles data save/load functionality in a binary format.

## Installation

1. Download a copy of the plug-in from GitHub.
1. Copy the `jc_savesystem` folder into your project's `addons/` directory.
2. Open **Project → Project Settings → Plugins**.
3. Enable **JC SaveSystem**.
4. The `SaveCoordinator` singleton is now available globally.
2. Set `SaveCoordinator.save_path` to the filepath where you want your save file to be stored.
    * default:  `user://save.dat`
3. Register the data you want to store via the class' static functions. e.g.:
    * `SaveCoordinator.set_data(&"my_data", {"type": "circle", "hole": "square"})`
4. Call the save function when you want to write your data to file.
    * `SaveCoordinator.save_game()`
5. Load the data and retrieve the values.
    ```
	SaveCoordinator.load_game()
	SaveCoordinator.get_data(&"my_data") # returns {"type": "circle", "hole": "square"}
	```

## Getting Started

```gdscript
# In any script, anywhere in your game:
SaveCoordinator.set_data(&"player_health", 100)
SaveCoordinator.save_game()

# Later, when loading:
SaveCoordinator.load_game()
var health = SaveCoordinator.get_data(&"player_health", 100)

## API

```
# save_coordinator.gd

static func save_game() -> bool # Returns false if there's no set data to save; true if successful.
static func load_game() -> bool # Returns false if there's no data retrieved; true if successful.
static func set_data(key: StringName, value: Variant, override: bool = true) -> bool # Stores value associated with key. By default, overwrites any existing data under the same key. Returns true if data was set.
static func get_data(key: StringName, default: Variant) -> Variant # Retrieves data stored under key, or default if it wasn't stored.
```

## TODO:
1. Asynchronous file read/write
2. Godot signal integration
3. Multiple save files
4. Save Encryption