# Area2D script
extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	get_tree().change_scene_to_file("res://scenes/BrickLevel.tscn")
