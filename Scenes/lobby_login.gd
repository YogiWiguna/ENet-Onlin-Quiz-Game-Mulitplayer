extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@export_file("*.tscn") var lobby_screen_scene

@onready var username = $Username
@onready var password = $Password
@onready var error_label = $ErrorLabel
@onready var login_button = $LoginButton
@onready var start_button = $StartButton
@onready var logged_players_label = $LoggedPlayersColorRect/Label


var peer = ENetMultiplayerPeer.new()
var is_peer_connected = false


func _ready():
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
	
	error_label.text = "Insert username and password"
	username.grab_focus()

func send_credentials():
	var user = username.text
	var password = password.text
	rpc_id(get_multiplayer_authority(), "authenticate_player", user, password)

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
		

func _on_start_button_pressed():
	rpc_id(get_multiplayer_authority(), "start_game")


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

@rpc
func add_logged_player(player_name):
	logged_players_label.text = logged_players_label.text + "\n%s" % player_name

@rpc("authority", "call_local")
func start_game():
	get_tree().change_scene_to_file(lobby_screen_scene)

