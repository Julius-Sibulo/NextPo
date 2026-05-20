extends Control

const MAIN_SCENE := "res://Main.tscn"
const SCREEN_DURATION := 5.0

const SCREENS := [
	{
		"text": "Disclaimer: This is a work of fiction. Any resemblance to actual persons is purely coincidental.",
		"show_image": false,
		"duration": 4.0,
	},
	{
		"text": "A person's freedom, livelihood, family, education, or future can depend on a missing photocopy, a mismatched date, or a single unchecked box.\n\nThe game critiques institutional bureaucracy and explores how rigid systems, time pressure, and performance metrics can erode human empathy, forcing individuals to choose between procedural correctness and moral responsibility.",
		"show_image": false,
		"duration": 10.0,
	},
	{
		"text": "You are hired as a Public Officer.",
		"show_image": true,
		"duration": 4.0,
	},
]

@onready var text_label: Label = $TextLabel
@onready var image_rect: TextureRect = $TextureRect
@onready var skip_button: Button = $SkipButton
@onready var timer: Timer = $Timer

var screen_index := 0
var is_transitioning := false

func _ready() -> void:
	modulate.a = 0.0
	skip_button.pressed.connect(_go_to_main)
	timer.timeout.connect(_advance_screen)
	_show_screen(0)

func _unhandled_input(event: InputEvent) -> void:
	var clicked := false
	
	if event is InputEventMouseButton:
		clicked = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	
	if event.is_action_pressed("ui_accept") \
	or event.is_action_pressed("ui_select") \
	or clicked:
		_advance_screen()

func _show_screen(index: int) -> void:
	screen_index = index
	var screen: Dictionary = SCREENS[screen_index]
	text_label.text = screen["text"]
	image_rect.visible = screen["show_image"]
	timer.start(screen.get("duration", SCREEN_DURATION))

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.45)

func _advance_screen() -> void:
	if is_transitioning:
		return
	if screen_index >= SCREENS.size() - 1:
		_go_to_main()
		return

	is_transitioning = true
	timer.stop()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func():
		is_transitioning = false
		_show_screen(screen_index + 1)
	)

func _go_to_main() -> void:
	timer.stop()
	get_tree().change_scene_to_file(MAIN_SCENE)
