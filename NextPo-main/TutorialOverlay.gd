extends CanvasLayer

@onready var dialogue_text: RichTextLabel = $PanelContainer/VBoxContainer/DialogueText
@onready var skip_btn: Button = $PanelContainer/VBoxContainer/HBoxContainer/SkipButton
@onready var next_btn: Button = $PanelContainer/VBoxContainer/HBoxContainer/NextButton
@onready var highlighter: ColorRect = $Highlighter

@onready var main_node = get_parent()

var current_step: int = 0

var tutorial_steps = [
	"\"Put your bag down. This is Window 3. You sit here.\"",
	"(Supervisor Abad drops a heavy, sterile binder onto your desk.)",
	"\"This is the official Agency Rulebook. It dictates your processing scope and limitations. Read it. If it is not documented, it is not valid.\"",
	"\"Here comes your first client. The timer starts the second they step up to the glass. You have 60 seconds. Do not hold up the line.\"",
	"\"They will slide their papers under the glass. Click these to review them. Check for missing signatures, expired IDs, and mismatched names.\"",
	"\"Once you read them, decide. Approve if it is clean. Reject if it is not. Request what is missing. If they cause a scene, Escalate it to me.\"",
	"\"The system tracks everything. Compliance is how strictly you follow procedure. Compassion is how much you bend the rules to help them.\"",
	"\"Your average becomes your Public Trust score, which you will see in your daily report. If Trust hits zero, you are terminated.\"",
	"\"Once you hit your daily quota, you can pack up. Hit this, and go home.\"",
	"\"That is all. Turn on your microphone and call the next one.\"",
	"\"Oh... and take this. It's the previous worker's manual. It's messy, but it's the only one you'll get.\""
]

func _ready() -> void:
	visible = true 
	highlighter.visible = false 
	
	skip_btn.pressed.connect(_on_skip_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	
	_show_current_step()

func _show_current_step() -> void:
	if current_step < tutorial_steps.size():
		dialogue_text.text = tutorial_steps[current_step]
		highlighter.visible = false 
		
		# Automatically close the official book if we are not on Step 2
		var off_book = main_node.get_node_or_null("OfficialBook")
		if current_step != 2 and off_book != null and off_book.visible == true:
			off_book.visible = false
		
		match current_step:
			1: # He drops the book
				var off_btn = main_node.get_node_or_null("OfficialBookButton")
				if off_btn:
					off_btn.visible = true
					_point_at(off_btn) 
			2: # He forces you to read it
				if off_book:
					off_book.visible = true 
					_point_at(off_book) 
			4: 
				var target = main_node.get_node_or_null("MarginContainer/VBoxContainer/BottomPanel/BottomVBox/ButtonRow")
				if target: _point_at(target)
			5:
				var target = main_node.get_node_or_null("MarginContainer/VBoxContainer/TopRow/RightPanel/RightBox/ChoicesGrid")
				if target: _point_at(target)
			6:
				var target = main_node.get_node_or_null("MarginContainer/VBoxContainer/TopRow/LeftPanel/MetersBox")
				if target: _point_at(target)
			8:
				var end_btn = main_node.get_node_or_null("EndShiftButton")
				if end_btn: _point_at(end_btn)
			10: # THE HANDOVER
				highlighter.visible = false 
				
				# Vaporize official assets
				var off_btn = main_node.get_node_or_null("OfficialBookButton")
				if off_btn: off_btn.queue_free()
				if off_book: off_book.queue_free()
					
				# Reveal the Lore Book
				var lore_btn = main_node.get_node_or_null("RulebookButton")
				if lore_btn:
					lore_btn.visible = true
					_point_at(lore_btn) 
		
		if current_step == tutorial_steps.size() - 1:
			next_btn.text = "Start Shift"
		else:
			next_btn.text = "Next >"
	else:
		_end_tutorial()

func _point_at(target_node: Control) -> void:
	if target_node:
		highlighter.visible = true
		var target_rect = target_node.get_global_rect()
		var padding = Vector2(20, 20)
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(highlighter, "global_position", target_rect.position - (padding / 2.0), 0.3)
		tween.tween_property(highlighter, "size", target_rect.size + padding, 0.3)

func _on_next_pressed() -> void:
	current_step += 1
	_show_current_step()

func _on_skip_pressed() -> void:
	# JUMP TO THE HANDOVER (Last Step)
	current_step = tutorial_steps.size() - 1
	_show_current_step()

func _end_tutorial() -> void:
	visible = false
	highlighter.visible = false
	
	# Vaporize official assets in case they were still there
	var off_book = main_node.get_node_or_null("OfficialBook")
	if off_book: off_book.queue_free()
		
	var off_btn = main_node.get_node_or_null("OfficialBookButton")
	if off_btn: off_btn.queue_free()
		
	# Ensure Lore Book button is visible
	var lore_btn = main_node.get_node_or_null("RulebookButton")
	if lore_btn: lore_btn.visible = true
		
	get_parent().start_gameplay_loop()
