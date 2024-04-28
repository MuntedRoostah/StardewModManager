extends Node

signal settings_closed

class Setting:
	enum typeEnum {StrBox, IntRange, FloatRange, IntBox, FloatBox, BoolToggle, PathBox}
	var setting_name:String
	var type:typeEnum
	var min
	var max
	var value
	func _init(display_name:String,setting_type:typeEnum, starting_value) -> void:
		setting_name = display_name
		type = setting_type
		value = starting_value
	func update(new_value):
		value = new_value
		print(value)
		

class Settings_page:
	var contents = []
	var page_name:String
	func _init(display_name:String, starting_settings=[]) -> void:
		page_name = display_name
		contents = starting_settings



var settings_window: Window

# all the settings go here

var mods_path = Setting.new("Path to mods", Setting.typeEnum.PathBox, "")

# and their pages here

var pages = [
	Settings_page.new("General",[mods_path])
]

func _on_settings_pressed() -> void:
	settings_window = preload("res://scenes/settings.tscn").instantiate()
	add_child(settings_window)
