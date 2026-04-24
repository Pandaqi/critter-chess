class_name PuzzleSettings

var config_path := "user://settings.cfg"
var config_section_key := "settings"
var config : ConfigFile

func initialize() -> void:
	load_config()
	
	# some shorthand caching for retrieving stuff more easily later
	# + update config to contain all settings and their defaults / latest setting
	for setting in PuzzleFramework.settings:
		PuzzleFramework.settings_by_id[setting.key] = setting
		var saved_value_or_default : Variant = get_config_value(setting.key)
		setting.set_value_from_config(saved_value_or_default)
	
	for difficulty in PuzzleFramework.difficulties:
		PuzzleFramework.difficulties_by_id[difficulty.difficulty] = difficulty

func load_config() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(config_path)
	
	# create the file first if non-existent
	if err != OK:
		cfg.save(config_path)
	
	# if still non-existent, actually break
	err = cfg.load(config_path)
	if err != OK:
		print("PuzzleSettings | Error | Failed to load config file.")
		return
	
	config = cfg

func save_config() -> void:
	config.save(config_path)

func set_config_value(key:String, val:Variant) -> void:
	config.set_value(config_section_key, key, val)
	save_config()

func get_config_value(key:String) -> Variant:
	return config.get_value(config_section_key, key, get_value(key))

static func get_difficulty() -> PuzzleDifficulty:
	return PuzzleFramework.difficulties[PuzzleFramework.current_difficulty]

static func get_difficulty_level() -> PuzzleDifficulty.Difficulty:
	return get_difficulty().difficulty

static func get_difficulty_string() -> String:
	return PuzzleDifficulty.Difficulty.keys()[get_difficulty_level()]

static func get_difficulty_property(key:String) -> Variant:
	var props := get_difficulty().properties
	if not (key in props): return null
	return props[key]

static func apply_difficulty_properties(obj) -> void:
	var diff := get_difficulty()
	for key in diff.properties:
		if not (key in obj): continue
		if typeof(obj[key]) == TYPE_ARRAY:
			obj[key].assign(diff.properties[key])
			continue
		obj[key] = diff.properties[key]

static func has_settings() -> bool:
	return PuzzleFramework.settings.size() > 0

static func get_value(key:String, def:Variant = false) -> Variant:
	if not (key in PuzzleFramework.settings_by_id): return def
	return PuzzleFramework.settings_by_id[key].get_value_safe()
