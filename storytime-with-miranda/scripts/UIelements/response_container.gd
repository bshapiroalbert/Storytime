extends PanelContainer

class_name ResponseContainer

@onready var response_list: VBoxContainer = $Panel/MarginContainer/ResponseList
@onready var response_button_0: ResponseButton = $Panel/MarginContainer/ResponseList/ResponseButton0

# Set the reponse text
func set_response(response_button: Button, response_text: String) -> void:
	response_button.text = response_text

# Function to add an arbitrary number of responses
func new_response(i, npc_dialog_array, responses) -> void:
	# Will probably want to make a custom button scene for responses at some point
	var response_button = response_button_0.duplicate()
	set_response(response_button, npc_dialog_array[responses[i]])
	response_button.name = "ResponseButton" + str(i)
	response_list.add_child(response_button)
	#response_list.position.y -= option_button.size.y + 5

# Function to remove any added responses
func reset_responses() -> void:
	var response_children = response_list.get_children()
	for response_child in response_children:
		if response_child.name != "ResponseButton0":
			#response_container.position.y += response_child.size.y + 5
			response_child.queue_free()
