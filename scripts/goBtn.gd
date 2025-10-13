# Area2D script
extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Get the menu node and trigger its transition
	var menu = get_node("/root/Menu")
	if menu and menu.has_method("_on_button_pressed"):
		menu._on_button_pressed()
