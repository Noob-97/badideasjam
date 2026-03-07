extends AudioStreamPlayer

var SONG = preload("res://Music/Game-jam.mp3")

func _ready() -> void:
	stream = AudioStreamMP3.new()
	stream.data = SONG.data
	play()
	finished.connect(play)
