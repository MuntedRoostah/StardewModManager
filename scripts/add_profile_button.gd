extends Node


signal add_new_profile

var profile_name = ""


func _on_add_pressed() -> void:
	var new_window = preload("res://scenes/addprofile.tscn").instantiate()
	add_child(new_window)
