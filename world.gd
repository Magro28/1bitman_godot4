extends Node2D

@export var next_Level: PackedScene

var level_time = 0.0
var start_level_msec

#drag and press control 
@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %LevelTimeLabel

func _ready():
	Events.level_completed.connect(show_level_completed)
	get_tree().paused = true
	LevelTransition.fade_from_black()
	animation_player.play("countdown")
	await animation_player.animation_finished
	get_tree().paused = false
	start_level_msec = Time.get_ticks_msec()
	
func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time/1000.0)

func retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	#var current_level = load(scene_file_path)
	get_tree().change_scene_to_file(scene_file_path)

func go_to_next_level():
	if not next_Level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_Level)
	

func show_level_completed():
	level_completed.show()
	level_completed.next_level_button.grab_focus()
	get_tree().paused = true
	

func _on_level_completed_retry():
	retry()


func _on_level_completed_next_level():
	go_to_next_level()

