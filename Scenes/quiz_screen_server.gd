extends Control


@export_file("*.json") var database_file = "res://Database/Database.json"
@export var turn_delay_in_seconds = 5.0

@onready var database = JSON.parse_string(FileAccess.open(database_file,FileAccess.READ).get_as_text())
@onready var quiz_panel = $QuizPanel
@onready var timer = $Timer
@onready var wait_label = $WaitLabel


func _ready():
	timer.start(3.0)
	await(timer.timeout)

@rpc("any_peer")
func answered(user):
	quiz_panel.rpc("update_winner", database[user]["name"])
	timer.start(turn_delay_in_seconds)
	wait_label.rpc("wait", turn_delay_in_seconds)

@rpc("any_peer")
func missed(user):
	quiz_panel.rpc("player_missed", database[user]["name"])
	timer.start(turn_delay_in_seconds)
	wait_label.rpc("wait", turn_delay_in_seconds)
