extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@export_file("*.tscn") var lobby_screen_scene

@onready var username = $Username
@onready var password = $Password
@onready var error_label = $ErrorLabel
@onready var login_button = $LoginButton

var peer = ENetMultiplayerPeer.new()
var is_peer_connected = false


func _ready():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
	
	error_label.text = "Insert username and password"
	username.grab_focus()




func _on_username_text_submitted(new_text):
	if not password.text == "":
		send_credentials()
	else:
		error_label.text = "Insert password"
		password.grab_focus()


func _on_password_text_submitted(new_text):
	if not username.text == "":
		send_credentials()
	else:
		error_label.text = "Insert username"
		username.grab_focus()

func _on_login_button_pressed():
	if username.text == "":
		error_label.text = "Insert username"
		username.grab_focus()
	elif password.text == "":
		error_label.text = "Insert password"
		password.grab_focus()
	else:
		send_credentials()
		

func send_credentials():
	var user = username.text
	var password = password.text

	rpc_id(get_multiplayer_authority(), "authenticate_player", user, password)


@rpc
func add_avatar(avatar_name, texture_path):
	pass


@rpc
func clear_avatars():
	pass


@rpc
func retrieve_avatar(user, session_token):
	pass


@rpc
func authenticate_player(user, password):
	pass


@rpc
func authentication_failed(error_message):
	error_label.text = error_message


@rpc
func authentication_succeed(session_token):
	AuthenticationCredentials.user = username.text
	AuthenticationCredentials.session_token = session_token
	get_tree().change_scene_to_file(lobby_screen_scene)



