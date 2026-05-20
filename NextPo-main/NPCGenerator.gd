@tool
extends EditorScript

func _run() -> void:
	print("Starting Advanced NPC Generation...")
	
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data/clients"):
		dir.make_dir_recursive("data/clients")

	var first_names = ["Mateo", "Sofia", "Gabriel", "Isabella", "Elias", "Camila", "Julian", "Luna", "Adrian", "Mia", "Leo", "Carmen", "Tomas", "Rosa", "Rafael", "Lucia", "Diego", "Valeria", "Emilio", "Martina", "Felix", "Clara", "Victor", "Elena", "Silvia"]
	var last_names = ["Reyes", "Bautista", "Cruz", "Villanueva", "Santos", "Mendoza", "Torres", "Navarro", "Castillo", "Rivera", "Aquino", "Ramos", "Delgado", "Castro", "Luna", "Flores", "Vargas", "Ortiz", "Morales"]
	
	var appearances = [
		"Looks exhausted, clutching a faded folder.",
		"Wearing a sharp suit, constantly checking their watch.",
		"Dressed in heavily stained work clothes.",
		"An older citizen leaning heavily on a wooden cane.",
		"A younger person nervously biting their lip.",
		"Staring right through you with an unblinking gaze.",
		"Smelling faintly of bleach and old paper.",
		"Wearing sunglasses indoors. Refuses to take them off.",
		"Keeps tapping their fingers rhythmically on the glass.",
		"Holding a crying infant in one arm while sorting papers.",
		"Covered in dust, like they just walked straight off a construction site."
	]

	var case_templates = [
		{
			"type": "Housing Transfer",
			"valid_doc": {"doc_type": "Zoning Form", "content": "District 4 Housing Transfer. Approved and stamped."},
			"invalid_docs": [
				{"doc_type": "Zoning Form", "flaw": "Missing Notary Stamp", "content": "District 4 Housing Transfer. Unsigned by notary."},
				{"doc_type": "Zoning Form", "flaw": "Wrong Name", "content": "District 4 Housing Transfer. The name on the lease doesn't match their ID."},
				{"doc_type": "Zoning Form", "flaw": "Missing Landlord Signature", "content": "District 4 Housing Transfer. The 'Property Owner' line is completely blank."},
				{"doc_type": "Zoning Form", "flaw": "Illegible", "content": "District 4 Housing Transfer. Someone spilled coffee entirely over the approval section."}
			],
			"lore": ["They are trying to move closer to the hospital.", "The rent at their current place tripled last month.", "Their current apartment's roof caved in."],
			"approve": "They packed up and moved the next day.",
			"reject": "They were forced to stay in their current, unsafe apartment.",
			"request": "They rushed to fix the paperwork and barely made it back before closing."
		},
		{
			"type": "Work Permit",
			"valid_doc": {"doc_type": "Employment Visa", "content": "Class B Labor Contract. Valid for 2 years."},
			"invalid_docs": [
				{"doc_type": "Employment Visa", "flaw": "Expired", "content": "Class B Labor Contract. Expired 3 weeks ago."},
				{"doc_type": "Employment Visa", "flaw": "Unregistered Employer", "content": "Class B Labor Contract. The listed company went bankrupt last year."},
				{"doc_type": "Employment Visa", "flaw": "Missing Work Role", "content": "Class B Labor Contract. The 'Job Title' section just says 'Stuff'."},
				{"doc_type": "Employment Visa", "flaw": "Forged Signature", "content": "Class B Labor Contract. The employer's signature is written in crayon."}
			],
			"lore": ["If they don't get this today, they lose the job offer.", "They've been unemployed for 8 months.", "They are sending money back to their family in the province."],
			"approve": "They started their new job and sent a thank-you note.",
			"reject": "They lost the job offer and remain unemployed.",
			"request": "They begged their employer for an extension to get the updated form."
		},
		{
			"type": "Medical Clearance",
			"valid_doc": {"doc_type": "Health Record", "content": "Cleared by City Hospital. No hazards detected."},
			"invalid_docs": [
				{"doc_type": "Health Record", "flaw": "Wrong Clinic", "content": "Cleared by unlicensed back-alley clinic."},
				{"doc_type": "Health Record", "flaw": "Missing Stamp", "content": "Health Record is filled out, but missing the official doctor's seal."},
				{"doc_type": "Health Record", "flaw": "Falsified Vitals", "content": "Health Record. Resting heart rate is listed as 0 BPM."},
				{"doc_type": "Health Record", "flaw": "Suspended Doctor", "content": "Cleared by Dr. Vance. (Notice: Dr. Vance lost his license in 2024)."}
			],
			"lore": ["They cough heavily into a handkerchief.", "They need this clearance to visit their family in the quarantine zone.", "They look perfectly healthy, but sweat profusely."],
			"approve": "They crossed the border. A minor outbreak occurred a week later.",
			"reject": "They were denied entry and had to return home sick.",
			"request": "They had to pay double for an expedited, legal checkup."
		},
		{
			"type": "Business License",
			"valid_doc": {"doc_type": "Merchant License", "content": "Authorized to sell goods in Sector 7."},
			"invalid_docs": [
				{"doc_type": "Merchant License", "flaw": "Incorrect Sector", "content": "Authorized to sell goods in Sector 2. (Applying for Sector 7)."},
				{"doc_type": "Merchant License", "flaw": "Missing Tax ID", "content": "Authorized to sell goods. The Tax Identification Number is missing."},
				{"doc_type": "Merchant License", "flaw": "Prohibited Goods", "content": "Applying to sell 'Unregulated Pharmaceuticals' in a school zone."},
				{"doc_type": "Merchant License", "flaw": "Unpaid Fees", "content": "Authorized to sell goods. 'OUTSTANDING BALANCE: $4,500' stamped in red."}
			],
			"lore": ["They just bought a food cart with their life savings.", "They brought a small basket of pastries, hoping to bribe you.", "They are trying to legitimize a family business."],
			"approve": "Their business flourished in the new sector.",
			"reject": "Their cart was confiscated by patrol officers the next day.",
			"request": "They lost a week of revenue waiting for the paperwork to clear."
		}
	]
	for i in range(50):
		var npc = NPCData.new()
		npc.npc_id = "gen_npc_" + str(i)
		npc.display_name = first_names.pick_random() + " " + last_names.pick_random()
		npc.appearance_description = appearances.pick_random()
		
		var template = case_templates.pick_random()
		
		var selected_lore = []
		var lore_pool = template["lore"].duplicate()
		lore_pool.shuffle()
		selected_lore.append(lore_pool[0])
		if randf() > 0.5:
			selected_lore.append(lore_pool[1])
			
		npc.lore_stages = selected_lore
		
		npc.consequence_if_approved = template["approve"]
		npc.consequence_if_rejected = template["reject"]
		npc.consequence_if_requested = template["request"]
		npc.consequence_if_escalated = "The supervisor handled the case and warned them about proper procedure."
		
		var is_perfect = randf() > 0.5
		
		var id_years = ["2021", "2022", "2023", "2024"]
		var id_doc = {"doc_type": "ID", "is_valid": true, "flaw": "", "content": "Standard Citizen ID. Issued " + id_years.pick_random() + ". Details match."}
		
		if is_perfect:
			var good_doc = template["valid_doc"].duplicate()
			good_doc["is_valid"] = true
			good_doc["flaw"] = ""
			npc.documents_per_visit.append([id_doc, good_doc])
		else:
		
			var bad_doc = template["invalid_docs"].pick_random().duplicate()
			bad_doc["is_valid"] = false
			npc.documents_per_visit.append([id_doc, bad_doc])
			
		
			var good_doc = template["valid_doc"].duplicate()
			good_doc["is_valid"] = true
			good_doc["flaw"] = ""
			npc.documents_per_visit.append([id_doc, good_doc])

		var save_path = "res://data/clients/" + npc.npc_id + ".tres"
		ResourceSaver.save(npc, save_path)
		
	print("Successfully generated 50 dynamic NPCs in res://data/clients/!")
