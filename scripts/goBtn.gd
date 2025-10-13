# Area2D script
extends Area2D

var players_on_button: Dictionary = {}
var transition_started: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	# Track which player entered
	if body.name == "Player" or body.name == "Player2":
		players_on_button[body.name] = true

		# Check if both players are now on the button
		if not transition_started and players_on_button.has("Player") and players_on_button.has("Player2"):
			transition_started = true
			# Get the menu node and trigger its transition
			var menu = get_tree().current_scene
			if menu and menu.has_method("_on_button_pressed"):
				menu._on_button_pressed()

func _on_body_exited(body):
	# Remove player from tracking when they leave
	if body.name == "Player" or body.name == "Player2":
		players_on_button.erase(body.name)
