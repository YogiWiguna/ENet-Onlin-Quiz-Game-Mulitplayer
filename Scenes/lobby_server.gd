extends Control

const PORT = 9999

@export var database_file_path = "res://Database/Database.json"
@export_file("*.tscn") var quiz_screen_scene_path = "res://Scenes/quiz_panel.tscn"
# high-level network interface for sending and receiving data between clients and the server and making RPCs
var peer = ENetMultiplayerPeer.new()

var database = {}
var logged_users = {}


func _ready():
	# Create a new multiplayer server that listens for incoming connections on the port number specified by the PORT variable
	peer.create_server(PORT)
	# This variable makes our peer object the default network interface for all nodes in the game
	multiplayer.multiplayer_peer = peer
	
	load_database()


func load_database(path_to_database_file = database_file_path):
	var file = FileAccess.open(path_to_database_file, FileAccess.READ)
	var file_content = file.get_as_text()
	database = JSON.parse_string(file_content)


@rpc("call_remote")
func add_avatar(avatar_name, texture_path):
	pass


@rpc("call_remote")
func clear_avatars():
	pass


@rpc("any_peer", "call_remote")
func retrieve_avatar(user, session_token):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if not user in logged_users:
		return
	if session_token == logged_users[user]:
		rpc("clear_avatars")
		for logged_user in logged_users:
			var avatar_name = database[logged_user]['name']
			var avatar_texture_path = database[logged_user]['avatar']
			rpc("add_avatar", avatar_name, avatar_texture_path)


@rpc("any_peer", "call_remote")
func authenticate_player(user, password):
	# This is how we identify who sent the request so we can properly respond to the request
	# Returns the sender's peer ID for the RPC currently being executed
	var peer_id = multiplayer.get_remote_sender_id()
	#print(peer_id)
	# Check if the user is not in the database
	if not user in database:
		# Send the methode authentication_failed with the error_message "User doesn't exist"
		rpc_id(peer_id, "authentication_failed", "User doesn't exist")
	# Check if password in database and password player's input is the same
	elif database[user]['password'] == password:
		# Set the token random
		var token = randi()
		# Set the key with user and the value with the token 
		logged_users[user] = token
		# Set rpc_id with peer_id (the user who requested) with function authentication_succeed with the token as the parameters 
		rpc_id(peer_id, "authentication_succeed", token)


@rpc
func authentication_failed(error_message):
	pass


@rpc
func authentication_succeed(session_token):
	pass


@rpc
func add_logged_player(player_name):
	pass

@rpc("any_peer","call_remote")
func start_game():
	rpc("start_game")
	get_tree().change_scene_to_file(quiz_screen_scene_path)
