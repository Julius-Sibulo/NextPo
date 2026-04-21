extends Node

signal day_started(day_number: int)
signal client_arrived(npc_data: NPCData)
signal decision_made(npc_data: NPCData, action: String)
signal day_ended(report: Array)

const MAX_DAYS: int = 6
const CLIENTS_PER_DAY: int = 15 #Maximum number of NPC 
const MIN_QUOTA: int = 5        

var current_day: int = 1
var current_client_index: int = 0
var daily_queue: Array[NPCData] = []
var daily_report: Array = []
var all_clients: Array[NPCData] = []

var scheduled_returns: Dictionary = {}

func _ready() -> void:
	_load_all_clients()
	await get_tree().create_timer(0.5).timeout
	start_day()

func _load_all_clients() -> void:
	var dir = DirAccess.open("res://data/clients/")
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if fname.ends_with(".tres"):
				var res = load("res://data/clients/" + fname) as NPCData
				if res:
					all_clients.append(res)
			fname = dir.get_next()
	else:
		print("WARNING: No generated NPCs found. Using fallback test clients.")
		all_clients = _get_test_clients()

func _get_test_clients() -> Array[NPCData]:
	# Fallback if the res://data/clients/ folder is empty
	var clients: Array[NPCData] = []
	var c1 = NPCData.new()
	c1.npc_id = "test_npc"
	c1.display_name = "Test Subject"
	c1.appearance_description = "A placeholder citizen."
	c1.lore_stages = ["Please generate NPCs using the Editor Script."]
	c1.documents_per_visit = [[{"doc_type": "ID", "is_valid": true, "flaw": "", "content": "Valid."}]]
	c1.consequence_if_approved = "Approved test."
	c1.consequence_if_rejected = "Rejected test."
	clients.append(c1)
	return clients

func start_day() -> void:
	daily_report.clear()
	_build_queue()
	current_client_index = 0
	emit_signal("day_started", current_day)
	await get_tree().create_timer(0.3).timeout
	_next_client()

func _build_queue() -> void:
	daily_queue.clear()
	
	if scheduled_returns.has(current_day):
		for client in scheduled_returns[current_day]:
			daily_queue.append(client)
			
	var available_pool = all_clients.duplicate()
	available_pool.shuffle()
	
	for client in available_pool:
		if daily_queue.size() >= CLIENTS_PER_DAY:
			break
			
		if not _is_client_unavailable(client):
			daily_queue.append(client)

func _is_client_unavailable(client: NPCData) -> bool:
	if client in daily_queue:
		return true
	if not client.interaction_history.is_empty():
		return true
	return false

func _next_client() -> void:
	if current_client_index >= daily_queue.size():
		force_end_day(true)
		return
	emit_signal("client_arrived", daily_queue[current_client_index])

func submit_decision(action: String) -> void:
	var client = daily_queue[current_client_index]
	client.record_interaction(current_day, action)

	var consequence := ""
	match action:
		"approve":  consequence = client.consequence_if_approved
		"reject":   consequence = client.consequence_if_rejected
		"request":  
			var will_return = randf() < 0.70 
			
			if will_return:
				consequence = client.consequence_if_requested
				var return_day = current_day + randi_range(1, 2)
				if not scheduled_returns.has(return_day):
					scheduled_returns[return_day] = [] as Array[NPCData]
				scheduled_returns[return_day].append(client)
			else:
				consequence = "They looked defeated when you asked for more papers. They never returned."

		"escalate": consequence = client.consequence_if_escalated

	daily_report.append({
		"client_name": client.display_name,
		"action": action,
		"consequence": consequence,
		"day": current_day
	})

	emit_signal("decision_made", client, action)
	current_client_index += 1
	await get_tree().create_timer(0.8).timeout
	_next_client()

func _end_day() -> void:
	if current_day >= MAX_DAYS:
		emit_signal("day_ended", daily_report)
		await get_tree().create_timer(2.0).timeout
		emit_signal("game_over_reached")
		return
	emit_signal("day_ended", daily_report)
	current_day += 1

func force_end_day(met_quota: bool) -> void:
	if not met_quota:
		daily_report.append({
			"client_name": "--- DEPARTMENT AUDIT ---",
			"action": "VIOLATION",
			"consequence": "Failed to meet the minimum processing quota of " + str(MIN_QUOTA) + " citizens. Severe penalties applied.",
			"day": current_day
		})
	_end_day()
