extends Control

# variables
var project_name     = ""
var project_location = ""

func _ready():
	Logger.info(name + " - node loaded")

# open the select the folder
func _on_BrowseButton_pressed():
	Logger.info(name + " _on_BrowseButton_pressed()")
	$FileDialog.popup_centered()

# name the project
func _on_LineEdit_text_changed(new_text):
	Logger.info(name + " _on_LineEdit_text_changed({0})".format([new_text]))
	project_name = new_text


# select dir
func _on_FileDialog_dir_selected(dir):
	Logger.info(name + " _on_FileDialog_dir_selected({0})".format([dir]))
	$VBoxContainer/VBoxContainer/Label2.text = dir
	project_location = dir


# create project
func _on_CreateButton_pressed():
	Logger.info(name + " _on_CreateButton_pressed()")
	if project_name == "":
		#throw out an error
		$Window.popup_centered()
		$Window/Label.text = "project name can't be empty"
		Logger.error(name + " _on_CreateButton_pressed()" + " aborted")
		Logger.error("project name is invalid")
	elif project_location == "":
		#throw out an error
		$Window.popup_centered()
		$Window/Label.text = "choose a directory to save the project"
		Logger.error(name + " _on_CreateButton_pressed()" + " aborted")
		Logger.error("browser has not been selected")
	else:
		# creates the project save file
		SystemSettings.add_new_project(project_name, project_location)
		ProjectSettingsManager.project_name      = project_name
		ProjectSettingsManager.project_location  = project_location
		SystemSettings.current_path              = project_location
		ProjectSettingsManager.date_of_creation  = OS.get_date()
		ProjectSettingsManager.save_file()

		SystemDataManager.load_root_folder_paths()
		ProjectSettingsManager.folder_integrity()
		SystemSettings.add_last_project_by_name(project_name, project_location)

		var _x = get_tree().change_scene_to_packed(load("res://systems/Dashboard.tscn"))
