extends Control

@onready var play_button = $CenterContainer/VBoxContainer/PlayButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	Global.compliance = 50
	Global.compassion = 50

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")
