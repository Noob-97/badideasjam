extends Label

@export var CurrentLevel: int
@export var LevelsFolder: String

@export_category("Controls")
@export var BasicControls:= false
@export var RetainKey := false
@onready var PlayerNode : Player = get_node("../Player")

func _ready() -> void:
	## Controls
	var show_controls = BasicControls or RetainKey
	if show_controls:
		text += "CONTROLS:\n--------------------------\n"
	# Basic Controls
	if BasicControls:
		text += "WASD to move\nright-click to switch gravities\nE to grab\n\nget to the end (green plate)!\n"
	# Retain Key
	if RetainKey:
		text += "press SHIFT to retain gravity\n"
	
	if show_controls:
		text += "\n"
	
	## Rules
	text += "RULES:\n"
	# Gravity Retain
	text += "- Gravity Retain: "
	if PlayerNode.GravityRetainEnabled:
		text += "Enabled\n"
	else:
		text += "Disabled\n"
	
	# Gravity Switch While Grabbing
	text += "- Gravity Switch While Grabbing: "
	if PlayerNode.SwitchGravityWhileGrabbingEnabled:
		text += "Enabled\n"
	else:
		text += "Disabled\n"
	
	text += "\n"
	
	## Level
	var numberoflevels = list_files_in_directory("res://" + LevelsFolder)
	text += "LEVEL " + str(CurrentLevel) + "/" + str(numberoflevels)
	
func list_files_in_directory(path) -> int:
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files.size()
