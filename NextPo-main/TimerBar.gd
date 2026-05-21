extends ProgressBar

signal time_expired

var time_remaining: float = 0.0
var running: bool = false

func start_timer(duration: float) -> void:
	max_value = duration
	time_remaining = duration
	value = duration
	running = true
	_update_clock_label() # Set initial time to 08:00

func stop_timer() -> float:
	running = false
	return time_remaining

func pause_timer() -> void:
	running = false

func resume_timer() -> void:
	if time_remaining > 0.0:
		running = true

func _process(delta: float) -> void:
	if not running:
		return

	time_remaining -= delta
	value = time_remaining


	var _fill = time_remaining / max_value
	if _fill < 0.25:
		modulate = Color(1.0, 0.3, 0.3)
	elif _fill < 0.5:
		modulate = Color(1.0, 0.75, 0.2)
	else:
		modulate = Color(0.4, 0.9, 0.5)

	
	_update_clock_label()

	if time_remaining <= 0.0:
		time_remaining = 0.0
		running = false
		_update_clock_label() 
		emit_signal("time_expired")


func _update_clock_label() -> void:
	if max_value <= 0: return 
	
	var time_elapsed = max_value - time_remaining
	var progress = time_elapsed / max_value
	
	var game_hours_passed = progress * 9.0 
	
	var current_hour = 8 + int(game_hours_passed)
	
	if current_hour >= 17:
		current_hour = 17
		
	
	var time_string = "%02d:00" % current_hour
	
	if has_node("ClockLabel"):
		$ClockLabel.text = time_string
