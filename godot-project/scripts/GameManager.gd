extends Node

signal score_changed(new_score: int)
signal level_changed(level_name: String)
signal game_over
signal game_paused

var score = 0
var current_level = 0
var is_game_over = false
var is_paused = false

var levels = [
	{"name": "Easy Street", "theme": "street", "background": "#2a2a3e", "difficulty": 1}
]

func _ready():
	# Initialize game
	reset_game()

func add_score(points: int):
	score += points
	score_changed.emit(score)

func reset_game():
	score = 0
	current_level = 0
	is_game_over = false
	is_paused = false
	score_changed.emit(score)
	level_changed.emit(levels[current_level]["name"])

func next_level():
	current_level = (current_level + 1) % levels.size()
	level_changed.emit(levels[current_level]["name"])

func pause_game():
	is_paused = true
	get_tree().paused = true
	game_paused.emit()

func resume_game():
	is_paused = false
	get_tree().paused = false

func end_game():
	is_game_over = true
	game_over.emit()