extends Control

@onready var play_button = $PlayButton
@onready var music_player = $MusicPlayer

func play_menu_music():
	music_player.stream = load("res://Assets/main-menu-bg-music.mp3")
	music_player.play()

func play_game_music():
	music_player.stream = load("res://Assets/clock-tick.mp3")
	music_player.play()

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	play_menu_music()
	Global.compliance = 50
	Global.compassion = 50

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")
