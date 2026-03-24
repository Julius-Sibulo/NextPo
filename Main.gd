extends Node2D

# ──────────────────────────────────────────
# GAME STATE
# ──────────────────────────────────────────
var compliance: int = 50
var compassion: int = 50
var current_case: Dictionary = {}
var case_index: int = 0

# ──────────────────────────────────────────
# CITIZEN CASE DATABASE
# ──────────────────────────────────────────
var cases: Array = [
	{
		"applicant": "Maria Santos",
		"request": "Senior Citizen Discount ID",
		"documents": "COMPLETE",
		"compliant": true,
		"urgency": "",
		"clear_compliance": 5,
		"clear_compassion": 3,
		"hold_compliance": -2,
		"hold_compassion": -2,
	},
	{
		"applicant": "Jose Reyes",
		"request": "Medical Assistance",
		"documents": "INCOMPLETE — Missing barangay certificate",
		"compliant": false,
		"urgency": "⚠️ Needed today — hospital admission",
		"clear_compliance": -5,
		"clear_compassion": 8,
		"hold_compliance": 5,
		"hold_compassion": -8,
	},
	{
		"applicant": "Ana Dela Cruz",
		"request": "Business Permit Renewal",
		"documents": "COMPLETE",
		"compliant": true,
		"urgency": "",
		"clear_compliance": 5,
		"clear_compassion": 2,
		"hold_compliance": -3,
		"hold_compassion": -1,
	},
	{
		"applicant": "Ramon Villanueva",
		"request": "Indigency Certificate",
		"documents": "INCOMPLETE — Missing valid ID",
		"compliant": false,
		"urgency": "",
		"clear_compliance": -4,
		"clear_compassion": 3,
		"hold_compliance": 4,
		"hold_compassion": -2,
	},
	{
		"applicant": "Lourdes Bautista",
		"request": "Scholarship Application",
		"documents": "INCOMPLETE — Missing grades",
		"compliant": false,
		"urgency": "⚠️ Deadline is today",
		"clear_compliance": -5,
		"clear_compassion": 7,
		"hold_compliance": 5,
		"hold_compassion": -7,
	},
]

# ──────────────────────────────────────────
# NODE REFERENCES
# ──────────────────────────────────────────
@onready var compliance_label = $ComplianceLabel
@onready var compassion_label = $CompassionLabel
@onready var applicant_label  = $ApplicantLabel
@onready var request_label    = $RequestLabel
@onready var documents_label  = $DocumentsLabel
@onready var urgency_label    = $UrgencyLabel
@onready var feedback_label   = $FeedbackLabel
@onready var clear_button     = $ClearButton
@onready var hold_button      = $HoldButton

# ──────────────────────────────────────────
# START
# ──────────────────────────────────────────
func _ready():
	clear_button.pressed.connect(_on_clear_pressed)
	hold_button.pressed.connect(_on_hold_pressed)
	load_case()

# ──────────────────────────────────────────
# LOAD NEXT CASE
# ──────────────────────────────────────────
func load_case():
	if case_index >= cases.size():
		show_end_screen()
		return

	current_case = cases[case_index]
	applicant_label.text  = "👤 Applicant: "  + current_case["applicant"]
	request_label.text    = "📋 Request: "    + current_case["request"]
	documents_label.text  = "📁 Documents: "  + current_case["documents"]
	urgency_label.text    = current_case["urgency"]
	feedback_label.text   = ""
	update_hud()

# ──────────────────────────────────────────
# BUTTON HANDLERS
# ──────────────────────────────────────────
func _on_clear_pressed():
	apply_effects(
		current_case["clear_compliance"],
		current_case["clear_compassion"]
	)
	show_feedback(
		current_case["clear_compliance"],
		current_case["clear_compassion"]
	)
	await get_tree().create_timer(1.5).timeout
	next_case()

func _on_hold_pressed():
	apply_effects(
		current_case["hold_compliance"],
		current_case["hold_compassion"]
	)
	show_feedback(
		current_case["hold_compliance"],
		current_case["hold_compassion"]
	)
	await get_tree().create_timer(1.5).timeout
	next_case()

# ──────────────────────────────────────────
# APPLY METER EFFECTS
# ──────────────────────────────────────────
func apply_effects(comp_change: int, comp2_change: int):
	compliance = clamp(compliance + comp_change, 0, 100)
	compassion = clamp(compassion + comp2_change, 0, 100)
	update_hud()

# ──────────────────────────────────────────
# SHOW FEEDBACK TEXT
# ──────────────────────────────────────────
func show_feedback(comp_change: int, comp2_change: int):
	var comp_text = ("⚖️ Compliance +" + str(comp_change)) if comp_change >= 0 else ("⚖️ Compliance " + str(comp_change))
	var comp2_text = ("❤️ Compassion +" + str(comp2_change)) if comp2_change >= 0 else ("❤️ Compassion " + str(comp2_change))
	feedback_label.text = comp_text + "     " + comp2_text

# ──────────────────────────────────────────
# NEXT CASE
# ──────────────────────────────────────────
func next_case():
	case_index += 1
	load_case()

# ──────────────────────────────────────────
# UPDATE HUD
# ──────────────────────────────────────────
func update_hud():
	compliance_label.text = "⚖️ Compliance: " + str(compliance)
	compassion_label.text = "❤️ Compassion: " + str(compassion)

# ──────────────────────────────────────────
# END SCREEN
# ──────────────────────────────────────────
func show_end_screen():
	applicant_label.text  = "— End of Queue —"
	request_label.text    = ""
	documents_label.text  = ""
	urgency_label.text    = ""
	feedback_label.text   = ""
	clear_button.disabled = true
	hold_button.disabled  = true

	if compliance >= 70 and compassion >= 70:
		compliance_label.text = "🏅 Result: BALANCED OFFICER"
		compassion_label.text = "You upheld the rules without losing your humanity."
	elif compliance >= 70:
		compliance_label.text = "📋 Result: BY-THE-BOOK OFFICER"
		compassion_label.text = "You followed every rule — but some people paid the price."
	elif compassion >= 70:
		compliance_label.text = "❤️ Result: COMPASSIONATE OFFICER"
		compassion_label.text = "You helped people — but bent the rules to do it."
	else:
		compliance_label.text = "⚠️ Result: UNDER REVIEW"
		compassion_label.text = "Neither consistent nor empathetic. Reconsider your approach."
