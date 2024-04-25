extends Node

func create(Title:String, Body:String, Button_text = "Close", Window_name = "Popup"):
	var new_popup = preload("res://scenes/popup.tscn").instantiate()
	new_popup.title = Window_name
	add_child(new_popup)
	var popup_vbox = new_popup.get_node("Panel/MarginContainer/VBoxContainer")
	
	popup_vbox.get_node("Popup_Title").text = "[center]"+Title+"[/center]"
	popup_vbox.get_node("Popup_Body").text = "[center]"+Body+"[/center]"
	popup_vbox.get_node("Popup_Button").text = Button_text
