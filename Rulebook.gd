# Rulebook.gd
# Attach to a PanelContainer node called "Rulebook"
# Add a Button somewhere in your Main scene called "RulebookButton" to toggle it
# Rulebook.gd
extends PanelContainer

# All pages: each has printed text and a handwritten note
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
		"printed": "Standard expectations:\n• Documents must be present\n• Documents must be readable\n• Information must be consistent\n\nMissing or invalid requirements may result in rejection.",
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
		"section": "Processing Time Protocol",
		"printed": "Time allocations:\n• Simple cases: 60–90 seconds\n• Standard cases: 90–150 seconds\n• Complex cases: 150–180 seconds",
		"note": "NEWSPAPER CLIPPING:\n\"Local man sentenced to 3 years after benefit appeal denied.\"\n\nIf I had approved it…\n\nAm I becoming this person?",
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

# --- SLIDE ANIMATION VARIABLES ---
# Adjust these based on your game's window size!
var hidden_y: float = 800.0  # Where it hides off-screen (bottom)
var shown_y: float = 150.0   # Where it rests on the desk

# --- UPDATED PATHS (Includes the new MarginContainer) ---
@onready var section_label: Label = $MarginContainer/VBoxContainer/SectionLabel
@onready var printed_text: RichTextLabel = $MarginContainer/VBoxContainer/PrintedText
@onready var handwritten_text: RichTextLabel = $MarginContainer/VBoxContainer/HandwrittenText
@onready var page_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/PageLabel
@onready var prev_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/PrevButton
@onready var next_btn: Button = $MarginContainer/VBoxContainer/HBoxContainer/NextButton
@onready var close_btn: Button = $MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	
	var screen_height = get_viewport_rect().size.y
	
	
	hidden_y = screen_height + 50.0 
	
	
	position.y = hidden_y
	visible = true 
	
	prev_btn.text = "< Prev"
	next_btn.text = "Next >"
	close_btn.text = "Close Rulebook"
	
	prev_btn.pressed.connect(_on_prev)
	next_btn.pressed.connect(_on_next)
	close_btn.pressed.connect(_on_close)
	
	_display_page()


func toggle() -> void:
	is_open = !is_open
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if is_open:
		_display_page() # Refresh the page before sliding it up
		tween.tween_property(self, "position:y", shown_y, 0.4)
	else:
		tween.tween_property(self, "position:y", hidden_y, 0.4)

func _display_page() -> void:
	var page = PAGES[current_page]

	section_label.text = page["section"].to_upper()
	printed_text.text = page["printed"]
	page_label.text = "Page %d of %d" % [current_page + 1, PAGES.size()]

	prev_btn.disabled = current_page == 0
	next_btn.disabled = current_page == PAGES.size() - 1

	var note = page["note"]
	if note.is_empty():
		handwritten_text.visible = false
		return

	handwritten_text.visible = true

	match page["note_style"]:
		"early":
		
			handwritten_text.add_theme_color_override("default_color", Color(0.2, 0.3, 0.8))
			handwritten_text.text = "✎  " + note
		"middle":
			
			handwritten_text.add_theme_color_override("default_color", Color(0.5, 0.1, 0.1))
			handwritten_text.text = note
		"late":
			
			handwritten_text.add_theme_color_override("default_color", Color(0.8, 0.1, 0.1))
			handwritten_text.text = note
		"final":
			
			handwritten_text.add_theme_color_override("default_color", Color(0.4, 0.4, 0.4))
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
