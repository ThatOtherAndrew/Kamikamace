extends Node

var player1_deaths = 0
var player2_deaths = 0
var player1_skulls: Array = []
var player2_skulls: Array = []
var is_resetting = false
var game_over = false
var skull_texture = preload("res://assets/skull.png")
var screen_tint: ColorRect

signal player_died(player_num: int)
signal level_reset()

func _ready():
    # Create UI overlay for death counter
    create_death_ui()

func create_death_ui():
    var canvas_layer = CanvasLayer.new()
    canvas_layer.layer = 100  # High layer to be on top of game
    add_child(canvas_layer)

    # Create 5 skulls for Player 1 (top left)
    for i in range(5):
        var skull = Sprite2D.new()
        skull.texture = skull_texture
        skull.position = Vector2(40 + (i * 36), 40)  # More padding and spacing
        skull.modulate = Color(0, 0, 0, 1)  # Start black
        skull.scale = Vector2(2, 2)  # Make them visible
        canvas_layer.add_child(skull)
        player1_skulls.append(skull)

    # Create 5 skulls for Player 2 (top right)
    var screen_width = 1152  # Based on your project resolution
    for i in range(5):
        var skull = Sprite2D.new()
        skull.texture = skull_texture
        skull.position = Vector2(screen_width - 40 - ((4 - i) * 36), 40)  # More padding and spacing
        skull.modulate = Color(0, 0, 0, 1)  # Start black
        skull.scale = Vector2(2, 2)
        canvas_layer.add_child(skull)
        player2_skulls.append(skull)

    # Create screen tint overlay (hidden initially)
    screen_tint = ColorRect.new()
    screen_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
    screen_tint.color = Color(0, 0, 0, 0)  # Start transparent
    screen_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas_layer.add_child(screen_tint)

func handle_player_death(player_num: int, death_position: Vector2):
    if is_resetting or game_over:
        return

    # Update death count and skull colors
    var winner = 0
    if player_num == 1:
        if player1_deaths < 5:
            player1_skulls[player1_deaths].modulate = Color(0.5, 0.5, 1, 1)  # Blue
        player1_deaths += 1
        if player1_deaths >= 5:
            winner = 1
    else:
        if player2_deaths < 5:
            player2_skulls[player2_deaths].modulate = Color(1, 0.5, 0.5, 1)  # Red
        player2_deaths += 1
        if player2_deaths >= 5:
            winner = 2

    # If there's a winner, apply screen tint immediately
    if winner > 0:
        game_over = true
        if winner == 1:
            screen_tint.color = Color(0.5, 0.5, 1, 0.3)  # Blue with transparency
        else:
            screen_tint.color = Color(1, 0.5, 0.5, 0.3)  # Red with transparency

    # Create explosion at death position
    create_explosion(death_position)

    # Hide the dead player
    emit_signal("player_died", player_num)

    # Start VHS rewind transition and wait for reset
    is_resetting = true

    # Wait 1.75 seconds, then start the VHS effect for the last 0.25 seconds
    await get_tree().create_timer(1.75).timeout

    # Start the VHS transition effect for the final 0.25 seconds
    if GlobalEffects:
        GlobalEffects.play_respawn_transition()

    await get_tree().create_timer(0.25).timeout
    reset_level()

    # If there was a winner, reset the game after normal death cycle
    if winner > 0:
        reset_game()

func create_explosion(pos: Vector2):
    var explosion = GPUParticles2D.new()
    get_tree().current_scene.add_child(explosion)
    explosion.position = pos
    explosion.emitting = true
    explosion.amount = 50
    explosion.lifetime = 1.0
    explosion.one_shot = true
    explosion.speed_scale = 2.0

    # Create process material
    var process_mat = ParticleProcessMaterial.new()
    process_mat.direction = Vector3(0, 0, 0)  # Direction is Vector3 in Godot 4
    process_mat.initial_velocity_min = 100.0
    process_mat.initial_velocity_max = 300.0
    process_mat.angular_velocity_min = -360.0
    process_mat.angular_velocity_max = 360.0
    process_mat.gravity = Vector3(0, 0, 0)  # No gravity for top-down - Vector3 in Godot 4
    process_mat.scale_min = 0.15  # 3x smaller
    process_mat.scale_max = 0.5   # 3x smaller
    process_mat.color = Color(1, 0.5, 0.2, 1)

    # Create and set gradient for color over lifetime
    var gradient = Gradient.new()
    gradient.add_point(0.0, Color(1, 1, 0, 1))  # Yellow
    gradient.add_point(0.3, Color(1, 0.5, 0, 1))  # Orange
    gradient.add_point(0.6, Color(1, 0, 0, 1))  # Red
    gradient.add_point(1.0, Color(0.5, 0, 0, 0))  # Dark red, transparent

    var gradient_texture = GradientTexture1D.new()
    gradient_texture.gradient = gradient
    process_mat.color_ramp = gradient_texture

    explosion.process_material = process_mat
    explosion.texture = preload("res://assets/mace.png")  # Use mace texture as particle

    # Clean up after explosion
    await explosion.finished
    explosion.queue_free()

func _on_powerup_collected(player):
    print("HEYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
    player.apply_speed_boost(1.5, 5.0)

func reset_game():
    # Reset death counts
    player1_deaths = 0
    player2_deaths = 0

    # Reset all skull colors back to black
    for skull in player1_skulls:
        skull.modulate = Color(0, 0, 0, 1)
    for skull in player2_skulls:
        skull.modulate = Color(0, 0, 0, 1)

    # Clear screen tint
    screen_tint.color = Color(0, 0, 0, 0)

    # Resume gameplay
    game_over = false

    # Reset level to respawn players
    emit_signal("level_reset")

func reset_level():
    emit_signal("level_reset")
    is_resetting = false
