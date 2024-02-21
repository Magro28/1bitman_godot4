extends CenterContainer

@onready var backto_menu_button = %BacktoMenuButton

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelTransition.fade_from_black()
	backto_menu_button.grab_focus()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://start_menu.tscn")
