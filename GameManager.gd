# GameManager.gd
extends Node

signal day_started(day_number: int)
signal calling_next_client # NEW SIGNAL FOR THE AUDIO
signal client_arrived(npc_data: NPCData)
signal decision_made(npc_data: NPCData, action: String)
signal day_ended(report: Array)

const MAX_DAYS: int = 6
const CLIENTS_PER_DAY: int = 15
const MIN_QUOTA: int = 5        

var current_day: int = 1
var current_client_index: int = 0
var daily_queue: Array[NPCData] = []
var daily_report: Array = []

var main_clients: Array[NPCData] = []
var generated_clients: Array[NPCData] = []
var scheduled_returns: Dictionary = {}

func _ready() -> void:
	_load_all_clients()

func _load_all_clients() -> void:
	var dir = DirAccess.open("res://data/clients/")
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if fname.ends_with(".tres"):
				var res = load("res://data/clients/" + fname) as NPCData
				if res:
					if res.npc_id.begins_with("gen_npc"):
						generated_clients.append(res)
					else:
						main_clients.append(res)
			fname = dir.get_next()
	else:
		print("WARNING: No generated NPCs found.")

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
			
	var lore_npc_added = false
	for main_npc in main_clients:
		if main_npc in daily_queue:
			lore_npc_added = true
			break

	if not lore_npc_added:
		for main_npc in main_clients:
			if main_npc.interaction_history.is_empty():
				daily_queue.append(main_npc)
				lore_npc_added = true
				break
			
	var available_pool = generated_clients.duplicate()
	available_pool.shuffle()
	
	for client in available_pool:
		if daily_queue.size() >= CLIENTS_PER_DAY: break
		if not _is_client_unavailable(client):
			daily_queue.append(client)
			
	daily_queue.shuffle()

func _is_client_unavailable(client: NPCData) -> bool:
	if client in daily_queue: return true
	if not client.interaction_history.is_empty(): return true
	return false

func _next_client() -> void:
	if current_client_index >= daily_queue.size():
		force_end_day(true)
		return
		
	# --- THE DRAMATIC PAUSE AND AUDIO CUE ---
	emit_signal("calling_next_client")
	await get_tree().create_timer(1.5).timeout # 1.5 second pause!
	# ----------------------------------------
	
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
			"consequence": "Failed to meet the minimum processing quota. Severe penalties applied.",
			"day": current_day
		})
	_end_day()
