extends Button
signal selected

var profile_name: String = ""
var hover = false

func _on_pressed():
	selected.emit()

func _ready():
	%Name.text = profile_name

func highlight():
	%Name.text = "> " + profile_name

func unhighlight():
	%Name.text = profile_name

