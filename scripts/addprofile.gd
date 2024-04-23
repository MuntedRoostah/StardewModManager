extends Window

func _on_close_requested() -> void:
	queue_free()

func _on_name_box_text_submitted(new_text: String) -> void:
	get_parent().profile_name = %NameBox.text
	get_parent().add_new_profile.emit(new_text)
