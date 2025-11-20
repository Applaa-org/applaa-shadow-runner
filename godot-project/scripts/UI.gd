extends CanvasLayer

@onready var start_screen = $StartScreen
@onready var game_over_screen = $GameOverScreen
@onready var pause_screen = $PauseScreen
@onready var score_label = $GameUI/ScoreLabel
@onready var level_label = $GameUI/LevelLabel
@onready var high_score_label = $GameUI/HighScoreLabel
@onready var level_progress = $GameUI/LevelProgress
@onready var controls_display = $GameUI/ControlsDisplay
@onready var start_button = $StartScreen/StartButton
@onready var restart_button = $GameOverScreen/RestartButton
@onready var resume_button = $PauseScreen/ResumeButton
@onready var main_menu_button = $PauseScreen/MainMenuButton
@onready var final_score_label = $GameOverScreen/FinalScoreLabel
@onready var level_complete_label = $LevelCompleteScreen

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Connect to GameManager signals
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.level_completed.connect(_on_level_completed)
	
	# Show start screen initially
	start_screen.visible = true
	game_over_screen.visible = false
	pause_screen.visible = false
	level_complete_label.visible = false
	
	# Update high score display
	update_high_score()

func hide_start_screen():
	start_screen.visible = false

func show_game_over_screen(final_score: int):
	game_over_screen.visible = true
	final_score_label.text = "Final Score: " + str(final_score)

func show_pause_screen():
	pause_screen.visible = true

func hide_pause_screen():
	pause_screen.visible = false

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_level(level_name: String):
	level_label.text = "Level: " + level_name
	update_level_progress()

func update_high_score():
	high_score_label.text = "High Score: " + str(GameManager.high_score)

func update_level_progress():
	var progress = GameManager.get_level_progress()
	level_progress.value = progress * 100

func show_level_complete(level_name: String):
	level_complete_label.visible = true
	level_complete_label.text = "Level Complete: " + level_name
	await get_tree().create_timer(2.0).timeout
	level_complete_label.visible = false

func _on_start_button_pressed():
	get_tree().call_group("main", "start_game")

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_resume_button_pressed():
	GameManager.resume_game()
	hide_pause_screen()

func _on_main_menu_button_pressed():
	get_tree().reload_current_scene()

func _on_score_changed(new_score: int):
	update_score(new_score)

func _on_level_changed(level_name: String):
	update_level(level_name)

func _on_game_over():
	show_game_over_screen(GameManager.score)

func _on_game_paused():
	show_pause_screen()

func _on_level_completed(level_name: String):
	show_level_complete(level_name)