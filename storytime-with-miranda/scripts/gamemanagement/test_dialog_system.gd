extends Node2D

# Child variables to access
@onready var dialog_layer: CanvasLayer = $DialogLayer
@onready var dialog_container: DialogContainer = $DialogLayer/DialogContainer
@onready var response_container: ResponseContainer = $DialogLayer/ResponseContainer

# Variables to get conversations from
var conversation_folder_path: String = "res://Conversations/"

# Other variables
var main_dialog_file = "res://Conversations/test_conversation.json"
var all_dialog
var npc_dialog
var next_response
var response_level
var message_idx = 0
var show_response = false # determine if we should show the responses or not yet
var more_responses = true # true if there are any more dialog responses
var dialog_box_char_limit = 145 # hard counted limit for now
var message_array_length
var dialog_target # the NPC, potential party member, etc. we're talking to
var dialog_target_name: String
var last_response: String = "Start" # the option that was last chosen for the response (A, B, AB, etc.)
var result_finished: bool = false

# Add signals
signal end_dialog

# Open the dialog box and play it
func open():
	dialog_container.visible = true
	dialog_container.play_dialog()

# Close the dialog box
func close():
	dialog_container.visible = false

func read_dialog(dialog_file):
	var file = FileAccess.open(dialog_file, FileAccess.READ)
	var content = file.get_as_text()
	var json_as_dict = JSON.parse_string(content)
	return json_as_dict

func _ready():
	all_dialog = read_dialog(main_dialog_file)

# function to break text into arrays to display
func clip_and_split_dialog(message):
	var message_array = []
	# Check if mesasge needs to be broken up
	if message.length() <= dialog_box_char_limit:
		message_array.append(message)
	else:
		var split_message = ""
		var string_idx = 0
		while string_idx < message.length():
			split_message += message[string_idx]
			if split_message.length() == dialog_box_char_limit:
				#find last instance of " "
				var last_space_idx = split_message.rfind(" ")
				# If there are no spaces, just cut it here
				if last_space_idx == -1:
					message_array.append(split_message)
					split_message = ""
				else:
					split_message = split_message.left(last_space_idx)
					message_array.append(split_message)
					split_message = ""
					string_idx -= (dialog_box_char_limit - last_space_idx)
			string_idx += 1
		# Add the last split
		message_array.append(split_message)
	return message_array

func start_dialog(npc_name, target):
	dialog_target = target
	dialog_target_name = npc_name
	# Make sure NPC has dialog to say
	if all_dialog[npc_name] == null:
		push_error("ERROR - no dialog for " + npc_name)
		return
	else:
		npc_dialog = all_dialog[npc_name]["Dialog"]
		# Split up into messages
		var message_array = clip_and_split_dialog(str(npc_dialog["Start"]))
		message_array_length = message_array.size()
		if message_array_length == 1 or message_idx == null:
			message_idx = 0
		dialog_container.set_character_name(npc_name)
		dialog_container.set_dialog_text(message_array[message_idx])
		open()
		# Check if reponse is necessary
		if message_array_length == (message_idx + 1):
			more_responses = true
			var responses = []
			for key in npc_dialog.keys():
				if "response" in key.to_lower():
					responses.append(key)
			# Add the necessary number of responses
			if len(responses) >= 1:
				response_container.set_response(response_container.response_button_0, npc_dialog[responses[0]])
				for i in range(1,len(responses)):
					response_container.new_response(i, npc_dialog, responses)
				# Show the response options
				show_response = true
				#dialog_popup.get_node("Response").visible = true
			else:
				more_responses = false

func next_dialog(next_reply, response_idx) -> void:
	# Split up into messages
	var message_array = []
	if next_response == null:
		message_array = clip_and_split_dialog(str(npc_dialog["Start"]))
	else:
		message_array = clip_and_split_dialog(str(npc_dialog[next_reply]))
	message_array_length = message_array.size()
	if message_array_length == 1:
			message_idx = 0
	dialog_container.set_dialog_text(message_array[message_idx])
	$"../AnimationPlayer".play("typewriter")
	# Check if reponse is necessary
	if message_array_length == (message_idx + 1) and next_reply != "Result":
		if response_idx == null:
			response_level = 0
		var responses = []
		for key in npc_dialog.keys():
			if "response" in key.to_lower():
				if len(key.split(" ")[-1]) > response_level:
					responses.append(key)
		# Add the necessary number of responses
		if len(responses) >= 1:
			response_container.set_response(response_container.response_button_0, npc_dialog[responses[0]])
			for i in range(1,len(responses)):
				response_container.new_response(i, npc_dialog, responses)
			# Show the response options
			show_response = true
		else:
			more_responses = false

func continue_dialog():
	# Check if animation is playing and if so end it early and show all text
	if $"../AnimationPlayer".is_playing():
		$"../AnimationPlayer".advance(1) # advance to the max length of typewriter animation, 1 second
		return
	# Check if waiting for a response. If so, do nothing
	if response_container.visible == true:
		return
	# Check if there's more dialog to display
	if message_array_length > 1:
		message_idx += 1
		next_dialog(next_response, response_level)
	elif message_array_length == 1:
		message_idx = 0
	# Check if waiting for any more responses
	if not more_responses:
		# Check if there should be a result
		if "Result" in all_dialog[dialog_target_name].keys() and not result_finished:
			_resolve_dialog_result(dialog_target_name, dialog_target)
		else:
			finish_dialog()

func finish_dialog() -> void:
	# close dialog_popup
	close()
	# remove responses options
	response_container.reset_responses()
	# reset dialog variables
	message_idx = 0
	next_response = null
	response_level = null
	more_responses = true
	show_response = false
	dialog_target = null
	last_response = "Start"
	dialog_target_name = ""
	result_finished = false
	# now reset dialog variable for player
	end_dialog.emit()

# Check if there should be any result or function called after the dialog is over
func _resolve_dialog_result(target_name, target):
	# Get the command for the result based on last response
	result_finished = true
	var result_command
	if last_response in all_dialog[target_name]["Result"]:
		result_command = all_dialog[target_name]["Result"][last_response]
	# If the last response doesn't lead to a result, just return and continue
	else:
		finish_dialog()
		return
	# Now have lots of different functions depending on the result
	# If the response lets the character join the party, let them join
	if result_command == "JoinParty":
		if target.is_in_group("PartyMember"):
			# Set some values to show the next dialog
			next_response = "Result"
			npc_dialog[next_response] = "%s joined the party!" % [target.character_name]
			next_dialog(next_response, response_level)
			# Call the join party function
			target.join_party()
		else:
			push_error("Target not a party member option: %s" % [target_name])
	
	# Other options could include getting an item or changing some variable somewhere
	else:
		push_error("No active resolution key found for result: %s" % [result_command])

func _get_next_response(button) -> void:
	# Get pressed response
	next_response = button.name.split("_")[-1]
	last_response = next_response # This is the mark of the option button, like A, AA, AB, etc.
	response_level = len(next_response)
	show_response = false
	response_container.visible = false
	next_dialog(next_response, response_level)

# Function for generic, non-NPC dialog (signs, chests, etc.)
func show_message(message):
	var message_array = clip_and_split_dialog(message)
	message_array_length = message_array.size()
	dialog_container.set_dialog_text(message_array[message_idx])
	if not dialog_container.visible:
		open()

func _on_animation_player_animation_finished(_anim_name):
	if show_response:
		response_container.visible = true
		# Focus on the first response button
		response_container.response_button_0.grab_focus()
