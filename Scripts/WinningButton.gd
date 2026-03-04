extends Area3D

@export var LevelsFolder:= "[folder_name]"
@export var NextLevelScene:= "[level_name]"

func _ready() -> void:
	body_entered.connect(CHECK_BODIES)

func CHECK_BODIES(body):
	if body is Player:
		print("LEVEL COMPLETED! Going to next level: " + NextLevelScene + " (" + LevelsFolder + ")")
		if LevelsFolder.is_empty():
			get_tree().call_deferred("change_scene_to_file", "res://" + NextLevelScene + ".tscn")
		else:
			get_tree().call_deferred("change_scene_to_file", "res://" + LevelsFolder + "/" + NextLevelScene  + ".tscn")
