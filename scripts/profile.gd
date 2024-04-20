extends Button
signal selected

var profile_name: String = ""
var hover = false

func _on_pressed():
	selected.emit()

func _ready():
	text = profile_name

func highlight():
	text = " < " + profile_name + " > "

func unhighlight():
	text = profile_name

