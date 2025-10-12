extends Area2D

@export var speed_multiplier := 5
@export var duration := 5.0

signal powerup_collected(player)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Something touched me:", body.name)  # DEBUG LINE
	print("Player touched power-up!")       # DEBUG LINE
	emit_signal("powerup_collected", body)
	queue_free()
