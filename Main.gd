extends Control

var current_case: Dictionary = {}
var case_index: int = 0

var cases: Array = [
	{
		"scenario": "Photocopy Missing",
		"description": "A man applies for a barangay clearance but only has his original ID — no photocopy.",
		"urgency": "Needs clearance today.",
		"choices": [
			{
				"text": "No photocopy,\nno processing.\nNext po.",
				"outcome": "Application rejected. Applicant leaves confused.",
				"compliance": 5,
				"compassion": -5,
			},
			{
				"text": "Photocopy shop\nis just outside.\nCome back after.",
				"outcome": "Applicant leaves to get a copy and may return.",
				"compliance": 5,
				"compassion": 5,
			},
			{
				"text": "I'll accept\nthe original\nfor now.",
				"outcome": "Processed without required copy.",
				"compliance": -5,
				"compassion": 5,
			},
			{
				"text": "*Does not check*\nReject.",
				"outcome": "Rejected without checking. Applicant leaves confused.",
				"compliance": -5,
				"compassion": -5,
			},
		],
		"docs": [
			{
				"name": "Valid ID",
				"present": true,
			},
			{
				"name": "Photocopy of ID",
				"present": false,
			},
		],
	},
	{
		"scenario": "Placeholder Scenario 2",
		"description": "A woman requests a certificate of indigency from the office.",
		"urgency": "",
		"choices": [
			{
				"text": "Rejected.\nMissing docs.",
				"outcome": "Application rejected.",
				"compliance": 5,
				"compassion": -5,
			},
			{
				"text": "Here is\nwhat you\nneed.",
				"outcome": "Citizen guided properly.",
				"compliance": 5,
				"compassion": 5,
			},
			{
				"text": "I'll process\nit anyway.",
				"outcome": "Processed incorrectly.",
				"compliance": -5,
				"compassion": 5,
			},
			{
				"text": "*Ignores*\nNext.",
				"outcome": "Citizen ignored.",
				"compliance": -5,
				"compassion": -5,
			},
		],
		"docs": [
			{
				"name": "Brgy. Certificate",
				"present": true,
			},
			{
				"name": "Valid ID",
				"present": false,
			},
		],
	},
	{
		"scenario": "Placeholder Scenario 3",
		"description": "An elderly man comes in for his senior citizen ID application.",
		"urgency": "He has been waiting since morning.",
		"choices": [
			{
				"text": "Come back\ntomorrow.",
				"outcome": "Sent away despite waiting.",
				"compliance": -3,
				"compassion": -8,
			},
			{
				"text": "I'll process\nthis now.",
				"outcome": "Processed correctly.",
				"compliance": 5,
				"compassion": 5,
			},
			{
				"text": "System is\ndown. Sorry.",
				"outcome": "Sent away with false excuse.",
				"compliance": -5,
				"compassion": -5,
			},
			{
				"text": "Let me\nask my\nsupervisor.",
				"outcome": "Case escalated appropriately.",
				"compliance": 3,
				"compassion": 3,
			},
		],
		"docs": [
			{
				"name": "Birth Certificate",
				"present": true,
			},
			{
				"name": "Valid ID",
				"present": true,
			},
		],
	},
	{
		"scenario": "Placeholder Scenario 4",
		"description": "A student needs a certificate of residency for a scholarship application.",
		"urgency": "Deadline is today.",
		"choices": [
			{
				"text": "Deadline is\nnot our\nproblem.",
				"outcome": "Student leaves without certificate.",
				"compliance": 3,
				"compassion": -8,
			},
			{
				"text": "I'll rush\nthis for\nyou.",
				"outcome": "Student gets certificate on time.",
				"compliance": 5,
				"compassion": 5,
			},
			{
				"text": "Come back\ntomorrow.",
				"outcome": "Student misses deadline.",
				"compliance": 3,
				"compassion": -8,
			},
			{
				"text": "Let me\nsee what\nI can do.",
				"outcome": "Student guided to correct process.",
				"compliance": 5,
				"compassion": 5,
			},
		],
		"docs": [
			{
				"name": "Valid ID",
				"present": true,
			},
			{
				"name": "Application Form",
				"present": true,
			},
		],
	},
]

@onready var compliance_label  = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/ComplianceLabel
@onready var compassion_label  = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/CompassionLabel
@onready var compliance_delta  = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/ComplianceDelta
@onready var compassion_delta  = $MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox/CompassionDelta
@onready var choice_a          = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceA
@onready var choice_b          = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceB
@onready var choice_c          = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceC
@onready var choice_d          = $MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid/ChoiceD
@onready var scenario_label    = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ScenarioLabel
@onready var description_label = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/DescriptionLabel
@onready var doc_button_1      = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/DocsRow/DocButton1
@onready var doc_button_2      = $MarginContainer/VBoxContainer/BottomPanel/BottomVBox/DocsRow/DocButton2
@onready var feedback_label    = $MarginContainer/VBoxContainer/FeedbackLabel

func _ready():
	choice_a.pressed.connect(_on_choice_pressed.bind(0))
	choice_b.pressed.connect(_on_choice_pressed.bind(1))
	choice_c.pressed.connect(_on_choice_pressed.bind(2))
	choice_d.pressed.connect(_on_choice_pressed.bind(3))
	compliance_delta.text = ""
	compassion_delta.text = ""
	load_case()

func load_case():
	if case_index >= cases.size():
		get_tree().change_scene_to_file("res://End.tscn")
		return

	current_case = cases[case_index]
	feedback_label.text   = ""
	compliance_delta.text = ""
	compassion_delta.text = ""

	var choices = current_case["choices"]
	choice_a.text = choices[0]["text"]
	choice_b.text = choices[1]["text"]
	choice_c.text = choices[2]["text"]
	choice_d.text = choices[3]["text"]

	scenario_label.text    = "Scenario: " + current_case["scenario"]
	description_label.text = current_case["description"]

	var docs = current_case["docs"]
	doc_button_1.text    = docs[0]["name"] if docs.size() > 0 else ""
	doc_button_2.text    = docs[1]["name"] if docs.size() > 1 else ""
	doc_button_1.visible = docs.size() > 0
	doc_button_2.visible = docs.size() > 1

	set_choices_visible(true)
	update_hud()

func _on_choice_pressed(index: int):
	var choice = current_case["choices"][index]
	Global.compliance = clamp(Global.compliance + choice["compliance"], 0, 100)
	Global.compassion  = clamp(Global.compassion  + choice["compassion"],  0, 100)
	update_hud()
	show_delta(choice["compliance"], choice["compassion"])
	feedback_label.text = "Outcome: " + choice["outcome"]
	set_choices_visible(false)
	await get_tree().create_timer(2.0).timeout
	next_case()

func set_choices_visible(value: bool):
	choice_a.visible = value
	choice_b.visible = value
	choice_c.visible = value
	choice_d.visible = value

func next_case():
	case_index += 1
	load_case()

func update_hud():
	compliance_label.text = "⚖ Compliance: " + str(Global.compliance)
	compassion_label.text = "❤ Compassion: "  + str(Global.compassion)

func show_delta(comp_change: int, comp2_change: int):
	compliance_delta.text = ("+ " + str(comp_change))  if comp_change  >= 0 else ("- " + str(abs(comp_change)))
	compassion_delta.text = ("+ " + str(comp2_change)) if comp2_change >= 0 else ("- " + str(abs(comp2_change)))
	compliance_delta.modulate = Color(0, 1, 0) if comp_change  >= 0 else Color(1, 0.3, 0.3)
	compassion_delta.modulate = Color(0, 1, 0) if comp2_change >= 0 else Color(1, 0.3, 0.3)
	await get_tree().create_timer(2.0).timeout
	compliance_delta.text = ""
	compassion_delta.text = ""
