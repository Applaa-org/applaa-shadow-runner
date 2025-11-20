extends Node

signal score_changed(new_score: int)
signal level_changed(level_name: String)
signal game_over

var score = 0
var current_level = 0
var is_game_over = false
var slowmo_active = false
var slowmo_timer = 0.0

var levels = [
	{"name": "Easy City", "theme": "city", "background": "#1a1a2e"},
	{"name": "Green Park", "theme": "park", "background": "#0d2818"},
	{"name": "Blue Sky", "theme": "sky", "background": "#1a3a5c"}
]

func _ready():
	# Initialize game
	reset_game()

func _process(delta):
	if slowmo_active:
		slowmo_timer -= delta
		if slowmo_timer <= 0:
			deactivate_slowmo()
			Engine.time_scale = 1.0

func add_score(points: int):
	score += points
	score_changed.emit(score)

func reset_game():
	score = 0
	current_level = 0
	is_game_over = false
	score_changed.emit(score)
	level_changed.emit(levels[current_level]["name"])

func next_level():
	current_level = (current_level + 1) % levels.size()
	level_changed.emit(levels[current_level]["name"])

func activate_slowmo():
	slowmo_active = true
	slowmo_timer = 5.0  # Longer duration
	Engine.time_scale = 0.5

func deactivate_slowmo():
	slowmo_active = false
	Engine.time_scale = 1.0

func end_game():
	is_game_over = true
	game_over.emit()