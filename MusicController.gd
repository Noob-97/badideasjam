extends AudioStreamPlayer

var SONG = load("res://Music/Game-jam.mp3")
var SONG_GRAVITY = load("res://Music/Game-jam-gravity.mp3")
var TITLE = load("res://Music/Menu-theme-i-guess.mp3")
var CREDITS = load("res://Music/Game-jam-idk-_1_.mp3")
var playback := 0.0
@onready var player : Player = get_node("/root/Node3D/Player")

func _ready() -> void:
	stream = AudioStreamMP3.new()
	if get_tree().current_scene.name == "TITLE":
		stream.data = TITLE.data
		play()
		finished.connect(play)
		return
	if get_tree().current_scene.scene_file_path == "res://first_level.tscn":
		stream.data = CREDITS.data
		play()
		finished.connect(play)
		return
	stream.data = SONG.data
	play()
	finished.connect(play)
	player.ChangedGravity.connect(change_song)

func change_song():
	playback = get_playback_position()
	stream = AudioStreamMP3.new()
	if player.char_component.gravity_mode:
		stream.data = SONG.data
	else:
		stream.data = SONG_GRAVITY.data
	play(playback)
