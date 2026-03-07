extends Area3D

@export var LevelsFolder:= "[folder_name]"
@export var NextLevelScene:= "[level_name]"

func _ready() -> void:
	body_entered.connect(CHECK_BODIES)

func CHECK_BODIES(body):
	if body is Player:
		print("LEVEL COMPLETED! Going to next level: " + NextLevelScene + " (" + LevelsFolder + ")")
		if LevelsFolder.is_empty():
			if ResourceLoader.exists("res://" + NextLevelScene + ".tscn"):
				get_tree().call_deferred("change_scene_to_file", "res://" + NextLevelScene + ".tscn")
			else:
				TESTING_PLACE()
		else:
			if ResourceLoader.exists("res://" + LevelsFolder + "/" + NextLevelScene  + ".tscn"):
				get_tree().call_deferred("change_scene_to_file", "res://" + LevelsFolder + "/" + NextLevelScene  + ".tscn")
			else:
				TESTING_PLACE()

func TESTING_PLACE():
	print("Couldn't find specified level. Going to testing place")
	LevelsFolder = ""
	NextLevelScene = "first_level"
	get_tree().call_deferred("change_scene_to_file", "res://" + NextLevelScene + ".tscn")
