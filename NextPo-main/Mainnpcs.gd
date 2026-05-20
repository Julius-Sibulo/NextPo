# MainNPCs.gd
# Run this as an Editor Script (like NPCGenerator.gd) to create the 3 main story NPCs.
# These are hand-crafted with full lore, multi-day document sets, and memory dialogue.
# Place this file in your project, then go: Tools > Execute Script

@tool
extends EditorScript

func _run() -> void:
	print("Generating 3 main story NPCs...")

	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data/clients"):
		dir.make_dir_recursive("data/clients")

	_create_scholarship_girl()
	_create_old_woman()
	_create_ex_convict()

	print("Done! 3 main NPCs saved to res://data/clients/")

# ─────────────────────────────────────────────────────────────────────────────
# NPC 1: ANA REYES — The Scholarship Girl
# A 19-year-old trying to claim a government scholarship grant.
# Her documents are almost always in order — but the system keeps finding
# reasons to delay her. The player slowly learns her mother is sick and the
# scholarship money is their only income.
# ─────────────────────────────────────────────────────────────────────────────
func _create_scholarship_girl() -> void:
	var npc = NPCData.new()
	npc.npc_id = "main_ana_reyes"
	npc.display_name = "Ana Reyes"

	npc.appearance_description = "A young woman, maybe 19, in a pressed school uniform that's slightly too small for her. She holds her folder with both hands like it might fly away. Her eyes are alert but ringed with tiredness."

	# Lore unfolds across days — player learns more each visit
	npc.lore_stages = [
		# Day 1 — First impression. Nothing unusual.
		"She smiles politely when you look up. She says she's here for her scholarship release form. Her handwriting on the form is careful and neat.",
		# Day 2 — She's been here before. Something is off.
		"She's back again. The collar of her uniform has a small stain she tried to cover with her bag strap. She quietly mentions she has a morning class she's already late for.",
		# Day 3 — The truth starts to show.
		"You notice she's wearing the same uniform as last time. She mentions, almost in passing, that her mother hasn't been well. She doesn't elaborate. She doesn't ask for sympathy. She just pushes her papers forward.",
		# Day 4 — The weight of it lands.
		"She's quieter today. When you ask if something is wrong, she says her mother was admitted to the hospital last week. The scholarship money — the grant she's been chasing through this office — is the only thing that would cover the bill. She doesn't cry. She just looks at you.",
		# Day 5 — Resolve or resignation.
		"She comes in without the folder today. Just her ID and a small envelope. Inside is a handwritten note from her mother — a co-signer form she managed to fill out from her hospital bed. Ana doesn't say anything. She just slides it across the counter."
	]

	# Documents change per visit — each day introduces a new bureaucratic hurdle
	npc.documents_per_visit = [
		# Visit 1 — One document has a minor flaw (grant form missing a reference number)
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #3821-A. Issued 2022. Photo matches. Name: Ana Reyes."},
			{"doc_type": "Scholarship Grant Form", "is_valid": false, "flaw": "Missing Reference Number", "content": "Dep't of Education Grant Form B-12. All fields filled. Reference number field is blank."},
			{"doc_type": "Enrollment Certificate", "is_valid": true, "flaw": "", "content": "Certified enrolled, 2nd Year, State University. AY 2024-2025. Signed by registrar."}
		],
		# Visit 2 — She fixed the reference number, but now needs a co-signer
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #3821-A. Issued 2022. Photo matches. Name: Ana Reyes."},
			{"doc_type": "Scholarship Grant Form", "is_valid": true, "flaw": "", "content": "Dep't of Education Grant Form B-12. Reference #GR-2024-0047. All fields complete."},
			{"doc_type": "Co-signer Form", "is_valid": false, "flaw": "Missing Co-signer Signature", "content": "Guardian Co-signer Declaration. Guardian name: Leonora Reyes. Signature line is blank."},
			{"doc_type": "Enrollment Certificate", "is_valid": true, "flaw": "", "content": "Certified enrolled, 2nd Year, State University. AY 2024-2025. Signed by registrar."}
		],
		# Visit 3 — All documents valid, but system flags a name discrepancy (middle name)
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #3821-A. Name: Ana M. Reyes."},
			{"doc_type": "Scholarship Grant Form", "is_valid": false, "flaw": "Name Mismatch", "content": "Grant Form lists name as 'Ana Reyes' — missing middle initial. System flags this as a discrepancy."},
			{"doc_type": "Co-signer Form", "is_valid": true, "flaw": "", "content": "Guardian Co-signer Declaration. Signed by Leonora Reyes. Notarized."},
			{"doc_type": "Enrollment Certificate", "is_valid": true, "flaw": "", "content": "Certified enrolled, 2nd Year. Name on record: Ana M. Reyes."}
		],
		# Visit 4 — Everything is finally valid
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #3821-A. Name: Ana M. Reyes. Issued 2022."},
			{"doc_type": "Scholarship Grant Form", "is_valid": true, "flaw": "", "content": "Grant Form B-12. Name: Ana M. Reyes. Reference #GR-2024-0047. All fields complete and verified."},
			{"doc_type": "Co-signer Form", "is_valid": true, "flaw": "", "content": "Co-signer Declaration. Signed by Leonora Reyes (guardian). Notarized and dated."},
			{"doc_type": "Hospital Co-signer Waiver", "is_valid": true, "flaw": "", "content": "Special waiver from City General Hospital allowing bedridden guardian to sign remotely. Verified seal present."}
		]
	]

	npc.consequence_if_approved = "Ana received the scholarship grant. Her mother's hospital bill was paid that same week. She passed all her subjects that semester."
	npc.consequence_if_rejected = "Ana dropped out of university the following month to work full time. Her mother's condition worsened without proper treatment."
	npc.consequence_if_requested = "Ana returned the next day, exhausted but with the corrected documents. She mentioned she hadn't slept."
	npc.consequence_if_escalated = "The supervisor reviewed her file and cited 'incomplete verification trail.' Her case was deferred to the next processing cycle — another two weeks."

	ResourceSaver.save(npc, "res://data/clients/main_ana_reyes.tres")
	print("  ✓ Ana Reyes saved.")


# ─────────────────────────────────────────────────────────────────────────────
# NPC 2: LOURDES SANTOS — The Old Woman
# A 71-year-old widow trying to transfer property title to her daughter
# before she undergoes a major surgery. Her documents are a mess — not
# from negligence, but from decades of neglect by the system itself.
# The player may initially find her irritating (slow, forgetful).
# The truth of why she's here arrives quietly.
# ─────────────────────────────────────────────────────────────────────────────
func _create_old_woman() -> void:
	var npc = NPCData.new()
	npc.npc_id = "main_lourdes_santos"
	npc.display_name = "Lourdes Santos"

	npc.appearance_description = "An old woman, maybe seventies, in a floral duster and worn sandals. She moves slowly. She asks you to repeat yourself twice before you've even spoken. She has a plastic folder held shut with a rubber band."

	npc.lore_stages = [
		# Day 1 — Slow, slightly frustrating. Nothing special yet.
		"She takes a long time to find each document. She apologizes repeatedly. She calls you 'anak.' She smells faintly of liniment oil.",
		# Day 2 — She remembers your name (or tries to). Something endearing.
		"She greets you like an old friend. She's brought a small plastic bag with a piece of homemade bibingka wrapped in foil. She sets it on the counter before you can say anything. 'You looked hungry last time,' she says.",
		# Day 3 — The reason behind the urgency.
		"She moves more carefully today. When she sits down to sort her papers, you notice a hospital bracelet still on her wrist from a recent admission. She says she needs to finish this before her operation next month.",
		# Day 4 — The full weight of it.
		"She tells you the land has been in her family for fifty years. She wants her daughter to have it before she goes in for surgery. 'Just in case,' she says, and smiles. The smile doesn't reach her eyes.",
		# Day 5 — Quiet determination.
		"She's brought her daughter today, a woman in her forties who holds her mother's arm. The daughter doesn't speak much, but she never lets go."
	]

	npc.documents_per_visit = [
		# Visit 1 — Old property title has a mismatch in address format
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "Senior Citizen ID. Name: Lourdes C. Santos. Issued 2019."},
			{"doc_type": "Property Title", "is_valid": false, "flaw": "Address Mismatch", "content": "TCT #44821. Property: Lot 12, Block 4, Mabini St. ID lists address as '12 Mabini Street' — format inconsistency flagged by system."},
			{"doc_type": "Transfer Request Form", "is_valid": true, "flaw": "", "content": "Property Transfer Form PT-7. From: Lourdes Santos. To: Carla Santos. Signed and dated."}
		],
		# Visit 2 — Address fixed, but title is under her deceased husband's name
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "Senior Citizen ID. Name: Lourdes C. Santos."},
			{"doc_type": "Property Title", "is_valid": false, "flaw": "Title Under Deceased Owner", "content": "TCT #44821. Registered owner: Eduardo Santos (deceased 2011). Requires death certificate and affidavit of heirship to transfer."},
			{"doc_type": "Transfer Request Form", "is_valid": true, "flaw": "", "content": "Property Transfer Form PT-7. Completed and notarized."},
			{"doc_type": "Death Certificate", "is_valid": true, "flaw": "", "content": "Death Certificate of Eduardo Santos. Issued by PSA. Dated March 4, 2011."}
		],
		# Visit 3 — Affidavit of heirship needed, she has one but it's expired
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "Senior Citizen ID. Name: Lourdes C. Santos."},
			{"doc_type": "Property Title", "is_valid": true, "flaw": "", "content": "TCT #44821. Now reflects Lourdes Santos as surviving heir. Updated."},
			{"doc_type": "Affidavit of Heirship", "is_valid": false, "flaw": "Expired Notarization", "content": "Affidavit of Heirship. Notarized 2013. System requires notarization within 5 years for property transfers."},
			{"doc_type": "Transfer Request Form", "is_valid": true, "flaw": "", "content": "Property Transfer Form PT-7. Completed and notarized."}
		],
		# Visit 4 — All valid. Finally.
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "Senior Citizen ID. Name: Lourdes C. Santos."},
			{"doc_type": "Property Title", "is_valid": true, "flaw": "", "content": "TCT #44821. Registered owner: Lourdes C. Santos. Address verified."},
			{"doc_type": "Affidavit of Heirship", "is_valid": true, "flaw": "", "content": "Affidavit of Heirship. Re-notarized 2024. Valid."},
			{"doc_type": "Transfer Request Form", "is_valid": true, "flaw": "", "content": "Property Transfer Form PT-7. Signed by Lourdes Santos and Carla Santos. Notarized. All fields complete."}
		]
	]

	npc.consequence_if_approved = "The title was transferred to her daughter Carla. Lourdes went into surgery two weeks later. She survived. When she was discharged, she told the nurse she had 'one less thing to worry about.'"
	npc.consequence_if_rejected = "Lourdes passed away during surgery three weeks later. The property remained under dispute. Her daughter spent the next two years in legal proceedings."
	npc.consequence_if_requested = "She came back the next day with the corrected document. Her daughter drove her. They waited in line for two hours."
	npc.consequence_if_escalated = "The supervisor deferred the case citing 'chain of title irregularities.' Lourdes was told to return in thirty days. She did not make it back."

	ResourceSaver.save(npc, "res://data/clients/main_lourdes_santos.tres")
	print("  ✓ Lourdes Santos saved.")


# ─────────────────────────────────────────────────────────────────────────────
# NPC 3: DANTE VILLANUEVA — The Ex-Convict
# A 38-year-old man trying to get a clearance certificate to apply for a job.
# He served 7 years for a crime he insists he didn't commit.
# On the surface he seems intimidating — quiet, guarded, deliberate.
# His documents are technically flawed in ways that are not his fault.
# The player's initial read of him is almost certainly wrong.
# ─────────────────────────────────────────────────────────────────────────────
func _create_ex_convict() -> void:
	var npc = NPCData.new()
	npc.npc_id = "main_dante_villanueva"
	npc.display_name = "Dante Villanueva"

	npc.appearance_description = "A large man in his late thirties wearing a clean but clearly second-hand collared shirt. He has a faded tattoo on the back of his left hand. He doesn't smile. He doesn't fidget. He just looks at you and waits."

	npc.lore_stages = [
		# Day 1 — First impression is intimidating. Nothing given away.
		"He slides his papers under the window without a word. When you look up, he holds your gaze for a moment longer than is comfortable. Then he looks away.",
		# Day 2 — Small crack in the surface.
		"He's early. He sits quietly in the waiting area for forty minutes before your window opens. When he finally approaches, he says, 'I need this to work. I have a daughter.'",
		# Day 3 — The system's record on him is wrong.
		"He shows you a printed document he brought himself — a news article from 2017. A retraction. The key witness in his case recanted. The case was supposedly under review. He says he doesn't know if anyone ever acted on it.",
		# Day 4 — The weight of seven years.
		"He's quieter today. You notice his hands are perfectly still on the counter. He says his daughter is eleven. He missed everything from age four to now. He's not asking for sympathy. He's just stating facts.",
		# Day 5 — Acceptance or exhaustion.
		"He comes in and sets his folder down and says, 'Whatever you decide.' He looks like he's made peace with something. Whether that peace is healthy or not is harder to say."
	]

	npc.documents_per_visit = [
		# Visit 1 — NBI clearance still shows prior conviction, not marked resolved
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #7741-D. Name: Dante R. Villanueva. Issued 2023 (post-release)."},
			{"doc_type": "NBI Clearance", "is_valid": false, "flaw": "Prior Record Not Cleared", "content": "NBI Clearance Form. Status: HIT. Case #CR-2016-0084 flagged. Note: case review status unknown."},
			{"doc_type": "Employment Application", "is_valid": true, "flaw": "", "content": "Application for warehouse staff position. Company: Laguna Cold Storage Inc. Start date contingent on clearance."}
		],
		# Visit 2 — He got a case review letter but it's not official clearance
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #7741-D. Name: Dante R. Villanueva."},
			{"doc_type": "NBI Clearance", "is_valid": false, "flaw": "Prior Record Not Cleared", "content": "NBI Clearance. Still reflects HIT status. Review not yet reflected in system."},
			{"doc_type": "Case Review Letter", "is_valid": false, "flaw": "Not Official Clearance", "content": "Letter from Regional Trial Court confirming case #CR-2016-0084 is under review. Not a clearance document. Cannot substitute."},
			{"doc_type": "Employment Application", "is_valid": true, "flaw": "", "content": "Application for warehouse staff. Offer extended pending clearance."}
		],
		# Visit 3 — NBI updated but employer's application is now expired
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #7741-D. Name: Dante R. Villanueva."},
			{"doc_type": "NBI Clearance", "is_valid": true, "flaw": "", "content": "NBI Clearance. Status: CLEARED. Case #CR-2016-0084 marked resolved. Issued this month."},
			{"doc_type": "Employment Application", "is_valid": false, "flaw": "Expired Application Window", "content": "Job application form. Original offer date: 45 days ago. Company policy: applications lapse after 30 days without clearance."},
		],
		# Visit 4 — New employer, all documents valid
		[
			{"doc_type": "Citizen ID", "is_valid": true, "flaw": "", "content": "National ID #7741-D. Name: Dante R. Villanueva."},
			{"doc_type": "NBI Clearance", "is_valid": true, "flaw": "", "content": "NBI Clearance. Status: CLEARED. Valid for 1 year from date of issue."},
			{"doc_type": "Employment Application", "is_valid": true, "flaw": "", "content": "New application: Security Staff, Balagtas Hardware Group. Application date: today. No expiry clause."},
			{"doc_type": "Character Reference Letter", "is_valid": true, "flaw": "", "content": "Letter of reference from Barangay Captain Isidro Manalang. Attests to Dante Villanueva's conduct since release. Signed and stamped."}
		]
	]

	npc.consequence_if_approved = "Dante got the job. Six months later he was promoted to shift supervisor. His daughter visited him at work on her birthday. He bought her a cake."
	npc.consequence_if_rejected = "Dante lost the job opportunity. He was back at the office three months later, this time for a different application. He didn't say anything when he saw you."
	npc.consequence_if_requested = "He returned the next morning before the office opened. He was already sitting outside when you arrived."
	npc.consequence_if_escalated = "The supervisor flagged his file for 'further background verification.' He was told the process could take 60 to 90 days. He nodded slowly and left."

	ResourceSaver.save(npc, "res://data/clients/main_dante_villanueva.tres")
	print("  ✓ Dante Villanueva saved.")
