extends Node2D

@onready var player = $Player
@onready var camera = $Camera2D
@onready var ui = $UI
@onready var level_generator = $LevelGenerator
@onready var game_manager = $GameManager

var game_started = false

func _ready():
	# Connect signals
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.level_changed.connect(_on_level_changed)
	game_manager.game_over.connect(_on_game_over)
	
	# Setup camera
	camera.position_smoothing_enabled = true

func _process(delta):
	if not game_started:
		if Input.is_action_just_pressed("ui_accept"):
			start_game()
	else:
		# Check if player fell off
		if player.global_position.y > 1000:
			game_manager.end_game()

func start_game():
	game_started = true
	ui.hide_start_screen()
	game_manager.reset_game()

func _on_score_changed(new_score):
	ui.update_score(new_score)

func _on_level_changed(level_name):
	ui.update_level(level_name)
	level_generator.generate_level(game_manager.current_level)

func _on_game_over():
	ui.show_game_over_screen(game_manager.score)