extends CanvasLayer

@onready var start_screen = $StartScreen
@onready var game_over_screen = $GameOverScreen
@onready var score_label = $GameUI/ScoreLabel
@onready var level_label = $GameUI/LevelLabel
@onready var controls_label = $GameUI/ControlsLabel
@onready var start_button = $StartScreen/StartButton
@onready var restart_button = $GameOverScreen/RestartButton
@onready var final_score_label = $GameOverScreen/FinalScoreLabel

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	
	# Show start screen initially
	start_screen.visible = true
	game_over_screen.visible = false
	
	# Show simple controls
	controls_label.text = "SPACEBAR = JUMP | DOWN ARROW = SLIDE"

func hide_start_screen():
	start_screen.visible = false

func show_game_over_screen(final_score: int):
	game_over_screen.visible = true
	final_score_label.text = "Final Score: " + str(final_score)

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_level(level_name: String):
	level_label.text = "Level: " + level_name

func _on_start_button_pressed():
	get_tree().call_group("main", "start_game")

func _on_restart_button_pressed():
	get_tree().reload_current_scene()