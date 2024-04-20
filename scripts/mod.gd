extends Control
signal enabled
signal disabled


var mod_name: String = ""
var mod_manifest: Dictionary = {}

func _ready():
	%Name.text = mod_name.substr(0, 32)
	if mod_manifest.has("Version"):
		%Version.text = "Version: " + mod_manifest["Version"].substr(0, 32)
	if mod_manifest.has("Author"):
		%Author.text = "Author: " + mod_manifest["Author"].substr(0, 32)
	if mod_manifest.has("Description"):
		%Description.text = mod_manifest["Description"].substr(0, 32)

func _on_check_box_toggled(button_pressed):
	if button_pressed:
		enabled.emit()
	else:
		disabled.emit()

func set_active(active):
	%CheckBox.set_pressed_no_signal(active)
