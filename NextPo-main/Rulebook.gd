# Rulebook.gd
# Attach to the Rulebook PanelContainer node in Main.tscn
# Slides in from the bottom when toggled. Contains official printed rules
# AND the handwritten notes of the previous worker — their emotional spiral
# mirrors what the player themselves may be experiencing.
extends PanelContainer

# ─── Page Data ────────────────────────────────────────────────────────────────
# Each page has:
#   section     — printed section header
#   printed     — the official bureaucratic text
#   note        — handwritten annotation from the previous worker (empty = none)
#   note_style  — "early" | "middle" | "late" | "final" (controls color/tone)

const PAGES = [
	{
		"section": "Job Overview",
		"printed": "Your role is simple: Process citizen applications quickly and correctly.\n\nApplications that meet requirements may proceed.\nApplications that do not meet requirements must not proceed.\n\nFailure is recorded.",
		"note": "",
		"note_style": "early"
	},
	{
		"section": "Processing Scope",
		"printed": "You are authorized to:\n• Inspect submitted documents\n• Compare information against system requirements\n• Approve compliant applications\n• Reject non-compliant applications\n\nYou are not required to:\n• Verify intent\n• Investigate background circumstances\n• Assume information not present in documents\n\nIf it is not documented, it is not valid.",
		"note": "Check dates twice. The system penalizes mismatches fast.",
		"note_style": "early"
	},
	{
		"section": "Document Requirements",
		"printed": "Standard expectations:\n• Documents must be present\n• Documents must be readable\n• Information must be consistent\n\nMissing or invalid requirements may result in rejection.\n\nRequired for ALL applicants:\n  — Citizen ID Card\n  — Assistance Request Form",
		"note": "A lot of the clients come back. Remember their names :)",
		"note_style": "early"
	},
	{
		"section": "Limitations",
		"printed": "You are not permitted to:\n• Interpret intent beyond provided documents\n• Override mandatory requirements without authorization\n• Base decisions solely on emotional circumstances\n• Request missing information outside system prompts",
		"note": "I followed the rules. I know I did.\n\nShe came back the next day crying. I still rejected it.\n\nI keep telling myself it wasn't my fault.",
		"note_style": "middle"
	},
	{
		"section": "Common Document Errors",
		"printed": "Errors that may require rejection:\n\n  Missing Document — e.g. no residency slip\n  Information Mismatch — different name or date\n  Missing Signature — unsigned authorization\n  Damaged / Unreadable — smudged or torn paper\n  Expired Document — past validity date\n  Wrong Issuing Authority — unrecognized clinic or office\n\nNote: The presence of a document does not guarantee its validity.",
		"note": "The rules don't tell you what to do when someone is crying.\n\nThey really don't.",
		"note_style": "middle"
	},
	{
		"section": "Processing Time Protocol",
		"printed": "Time allocations:\n• Simple cases: 60–90 seconds\n• Standard cases: 90–150 seconds\n• Complex cases: 150–180 seconds\n\nProcessing beyond allocated time is logged.\nFailing to meet the daily quota is penalized.",
		"note": "[ NEWSPAPER CLIPPING, taped to the page ]\n\n\"Local man sentenced after benefit appeal denied.\"\n\n——\n\nIf I had approved it…\n\nAm I becoming this person?",
		"note_style": "late"
	},
	{
		"section": "Final Notice",
		"printed": "You are not evaluating people.\n\nYou are evaluating documents.",
		"note": "I can still hear them at the counter.",
		"note_style": "final"
	},
]

var current_page: int = 0
var is_open: bool = false

var hidden_y: float = 800.0
var shown_y: float = 150.0

@onready var section_label: Label        = $MarginContainer/VBoxContainer/SectionLabel
@onready var printed_text: RichTextLabel = $MarginContainer/VBoxContainer/PrintedText
@onready var handwritten_text: RichTextLabel = $MarginContainer/VBoxContainer/HandwrittenText
@onready var page_label: Label           = $MarginContainer/VBoxContainer/HBoxContainer/PageLabel
@onready var prev_btn: Button            = $MarginContainer/VBoxContainer/HBoxContainer/PrevButton
@onready var next_btn: Button            = $MarginContainer/VBoxContainer/HBoxContainer/NextButton
@onready var close_btn: Button           = $MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	var screen_height = get_viewport_rect().size.y
	hidden_y = screen_height + 50.0
	position.y = hidden_y
	visible = true

	prev_btn.text  = "< Prev"
	next_btn.text  = "Next >"
	close_btn.text = "Close Rulebook"

	prev_btn.pressed.connect(_on_prev)
	next_btn.pressed.connect(_on_next)
	close_btn.pressed.connect(_on_close)

	_display_page()

# ─── Toggle (called by RulebookButton in Main.gd) ─────────────────────────────
func toggle() -> void:
	is_open = !is_open
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if is_open:
		_display_page()
		tween.tween_property(self, "position:y", shown_y, 0.4)
	else:
		tween.tween_property(self, "position:y", hidden_y, 0.4)

# ─── Page Display ─────────────────────────────────────────────────────────────
func _display_page() -> void:
	var page = PAGES[current_page]

	section_label.text = page["section"].to_upper()
	printed_text.text  = page["printed"]
	page_label.text    = "Page %d of %d" % [current_page + 1, PAGES.size()]

	prev_btn.disabled = (current_page == 0)
	next_btn.disabled = (current_page == PAGES.size() - 1)

	var note = page["note"]
	if note.is_empty():
		handwritten_text.visible = false
		return

	handwritten_text.visible = true

	match page["note_style"]:
		"early":
			# Helpful, neat, optimistic — blue ink, tidy
			handwritten_text.add_theme_color_override("default_color", Color(0.2, 0.3, 0.8))
			handwritten_text.text = "✎  " + note
		"middle":
			# Guilt setting in — dark red, less tidy
			handwritten_text.add_theme_color_override("default_color", Color(0.5, 0.1, 0.1))
			handwritten_text.text = note
		"late":
			# Emotional spiral — bright red, erratic
			handwritten_text.add_theme_color_override("default_color", Color(0.85, 0.1, 0.1))
			handwritten_text.text = note
		"final":
			# Faded, exhausted — grey
			handwritten_text.add_theme_color_override("default_color", Color(0.45, 0.45, 0.45))
			handwritten_text.text = note

func _on_prev() -> void:
	if current_page > 0:
		current_page -= 1
		_display_page()

func _on_next() -> void:
	if current_page < PAGES.size() - 1:
		current_page += 1
		_display_page()

func _on_close() -> void:
	toggle()
