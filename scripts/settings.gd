extends Window

var settings_manager

var unsaved_changes = false

@export var strbox_scene:PackedScene
@export var intrange_scene:PackedScene
@export var floatrange_scene:PackedScene
@export var intbox_scene:PackedScene
@export var floatbox_scene:PackedScene
@export var booltoggle_scene:PackedScene

@export var page_scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title = "Settings"
	settings_manager = get_parent()
	
	## Generate the settings
	
	for page in settings_manager.pages:
		var new_page = page_scene.instantiate()
		new_page.name = page.page_name
		%TabContainer.add_child(new_page)
		for setting in page.contents:
			var new_setting
			if setting.type == settings_manager.Setting.typeEnum.StrBox:
				new_setting = strbox_scene.instantiate()
				new_setting.get_node("Label").text = setting.setting_name
				new_setting.get_node("Input").text = setting.value
				new_setting.get_node("Input").text_changed.connect(setting.update)
			else:
				new_setting = booltoggle_scene.instantiate()
				new_setting.get_node("Label").text = setting.setting_name				
				new_setting.get_node("Input").button_pressed = setting.value
				new_setting.get_node("Input").toggled.connect(setting.update)
			new_page.add_child(new_setting)

func _on_close_requested() -> void:
	settings_manager.settings_closed.emit()
	queue_free()
	pass
