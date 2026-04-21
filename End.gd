extends Control

@onready var compliance_result = $CenterContainer/VBoxContainer/ComplianceResultLabel
@onready var compassion_result = $CenterContainer/VBoxContainer/CompassionResultLabel
@onready var result_label      = $CenterContainer/VBoxContainer/ResultLabel
@onready var description_label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var play_again_button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var quit_button       = $CenterContainer/VBoxContainer/QuitButton


func _ready():
	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	compliance_result.text = "Compliance: " + str(Global.compliance)
	compassion_result.text = "Compassion: " + str(Global.compassion)

	if Global.compliance >= 70 and Global.compassion >= 70:
		result_label.text      = "BALANCED OFFICER"
		description_label.text = "You upheld the rules without losing your humanity."
	elif Global.compliance >= 70:
		result_label.text      = "BY-THE-BOOK OFFICER"
		description_label.text = "You followed every rule — but some people paid the price."
	elif Global.compassion >= 70:
		result_label.text      = "COMPASSIONATE OFFICER"
		description_label.text = "You helped people — but bent the rules to do it."
	else:
		result_label.text      = "UNDER REVIEW"
		description_label.text = "Neither consistent nor empathetic. Reconsider your approach."

func _on_play_again_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_quit_pressed():
	get_tree().quit()
