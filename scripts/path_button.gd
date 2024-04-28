extends Button


func _pressed() -> void:
	%FileDialog.visible = true


func _on_file_dialog_dir_selected(dir: String) -> void:
	%Input.text = dir
