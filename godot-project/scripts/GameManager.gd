extends Node

signal score_changed(new_score: int)
signal level_changed(level_name: String)
signal game_over
signal game_paused

var score = 0
var current_level = 0
var is_game_over = false
var is_paused = false
var slowmo_active = false
var slowmo_timer = 0.0

var levels = [
	{"name": "City Rooftops", "theme": "city", "background": "#1a1a2e"},
	{"name": "Old Ruins", "theme": "ruins", "background": "#3d2817"},
	{"name": "Jungle Temple", "theme": "jungle", "background": "#0d2818"},
	{"name": "Cyber World", "theme": "cyber", "background": "#0a0a0a"}
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
	is_paused = false
	score_changed.emit(score)
	level_changed.emit(levels[current_level]["name"])

func next_level():
	current_level = (current_level + 1) % levels.size()
	level_changed.emit(levels[current_level]["name"])

func activate_slowmo():
	slowmo_active = true
	slowmo_timer = 3.0
	Engine.time_scale = 0.5

func deactivate_slowmo():
	slowmo_active = false
	Engine.time_scale = 1.0

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