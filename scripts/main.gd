extends Control

const CONFIG_PATH = "user://config.cfg"
const PROFILE_PATH = "user://profiles.json"

@export var mod_scene: PackedScene
@export var profile_scene: PackedScene


var profiles: Dictionary = {}
var selected_profile: String = ""
var config: ConfigFile = ConfigFile.new()
var inactive_mods_path: String = ""
var exe_path: String = ""
var mod_list: Array[String] = []

func _ready():
	self.get_viewport().set_embedding_subwindows(false)
	get_viewport().get_window().title = "StardewModManager"
	load_config()
	load_mods()
	load_profiles()
	%Mods.hide()



func _on_name_box_text_submitted(new_text: String):
	if not new_text.strip_edges():
		return # dont add empty profiles
	%AddProfile.profile_name = ""
	new_profile(new_text)

func load_profiles() -> void:
	if not FileAccess.file_exists(PROFILE_PATH):
		var file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(profiles))
		return
	var file = FileAccess.open(PROFILE_PATH, FileAccess.READ)
	var profile_data = JSON.parse_string(file.get_as_text())
	profiles = profile_data if profile_data else {}
	for child in %Profiles.get_children():
		%Profiles.remove_child(child)
	for prof in profiles:
		add_profile_button(prof)
	
func save_profiles() -> void:
	var file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(profiles))

func load_mods() -> void:
	if not%Settings.mods_path.value:
		return
	for child in %Mods.get_children():
		%Mods.remove_child(child)
	disable_mods()
	var inactive_mods_dir = DirAccess.open(inactive_mods_path)
	for mod in inactive_mods_dir.get_directories():
		var manifest_path = inactive_mods_path + "/" + mod + "/manifest.json"
		var manifest = {}
		mod_list.append(mod)
		if FileAccess.file_exists(manifest_path):
			var lines = FileAccess.open(manifest_path, FileAccess.READ).get_as_text().split("\n")
			var cleaned_lines = []
			for line in lines:
				if not line.strip_edges().begins_with("//"):
					cleaned_lines.append(line)
			var cleaned_content: String = "\n".join(cleaned_lines)
			while cleaned_content.contains("/*") and cleaned_content.find("*/", cleaned_content.find("/*")) >= 0:
				var start = cleaned_content.find("/*")
				var end = cleaned_content.find("*/", start)
				cleaned_content = cleaned_content.erase(start, end - start + 2)
			
			manifest = JSON.parse_string(cleaned_content)
		var mod_box = mod_scene.instantiate()
		mod_box.mod_name = mod
		mod_box.mod_manifest = manifest
		%Mods.add_child(mod_box)
		mod_box.enabled.connect(add_mod.bind(mod))
		mod_box.disabled.connect(remove_mod.bind(mod))

func disable_mods():
	var mods_dir = DirAccess.open(%Settings.mods_path.value)
	for mod in mods_dir.get_directories():
		mods_dir.rename(mod, inactive_mods_path + "/" + mod)

func enable_mod(mod):
	var inactive_mods_dir = DirAccess.open(inactive_mods_path)
	if not inactive_mods_dir.dir_exists(mod):
		return
	inactive_mods_dir.rename(mod,%Settings.mods_path.value + "/" + mod)

func disable_mod(mod):
	var mods_dir = DirAccess.open(%Settings.mods_path.value)
	if not mods_dir.dir_exists(mod):
		return
	mods_dir.rename(mod, inactive_mods_path + "/" + mod)

func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		config.set_value("paths", "mods", "")
		config.save(CONFIG_PATH)
		return
	config.load(CONFIG_PATH)
	%Settings.mods_path.value = config.get_value("paths", "mods")
	inactive_mods_path = config.get_value("paths", "inactivemods")
	exe_path = config.get_value("paths", "exe")

func set_mods_path(value: String):
	value = value.replace("\\", "/")
	value = value.rstrip("/")
	%Settings.mods_path.value = value
	var content_dir = value.rsplit("/", true, 1)[0]
	inactive_mods_path = content_dir + "/InactiveMods"
	exe_path = content_dir + "/StardewModdingAPI.exe"
	if not FileAccess.file_exists(exe_path):
		return
	if not DirAccess.dir_exists_absolute(inactive_mods_path):
		DirAccess.make_dir_absolute(inactive_mods_path)
	config.set_value("paths", "mods", value)
	config.set_value("paths", "inactivemods", inactive_mods_path)
	config.set_value("paths", "exe", exe_path)
	config.save(CONFIG_PATH)
	load_mods()
	
func new_profile(prof: String):
	if profiles.has(prof):
		return
	profiles[prof] = []
	save_profiles()
	add_profile_button(prof).selected.emit()
	
func add_profile_button(prof: String):
	var pb = profile_scene.instantiate()
	pb.profile_name = prof
	%Profiles.add_child(pb)
	pb.selected.connect(select_profile.bind(pb, prof))
	pb.name = prof
	return pb
	
func select_profile(pb, prof: String):
	selected_profile = prof
	for child in %Profiles.get_children():
		child.unhighlight()
	pb.highlight()
	for child in %Mods.get_children():
		child.set_active(child.mod_name in profiles[selected_profile])
	disable_mods()
	for mod in profiles[selected_profile]:
		enable_mod(mod)
	%Mods.show()

func add_mod(mod: String):
	if not selected_profile:
		return
	if not mod_list.has(mod):
		return
	profiles[selected_profile].append(mod)
	save_profiles()
	enable_mod(mod)

func remove_mod(mod: String):
	if not selected_profile:
		return
	if not mod_list.has(mod):
		return
	profiles[selected_profile].erase(mod)
	save_profiles()
	disable_mod(mod)

func _on_path_box_text_submitted():
	set_mods_path(%Settings.mods_path.value)

func _on_delete_pressed():
	if not selected_profile:
		return
	delete_profile(selected_profile)
	selected_profile = ""
	%Mods.hide()
	disable_mods()
	
func delete_profile(prof):
	profiles.erase(prof)
	save_profiles()
	%Profiles.remove_child(%Profiles.get_node(prof))


func _on_launch_pressed():
	if not exe_path: return
	OS.create_process(exe_path, [], true)


func _on_add_profile_add_new_profile(new_string):
	_on_name_box_text_submitted(new_string)


func _on_settings_settings_closed() -> void:
	_on_path_box_text_submitted()
