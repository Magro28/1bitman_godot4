extends Node2D

@export var next_Level: PackedScene

#drag and press control 
@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var animation_player = $AnimationPlayer

func _ready():
	Events.level_completed.connect(show_level_completed)
	get_tree().paused = true
	LevelTransition.fade_from_black()
	animation_player.play("countdown")
	await animation_player.animation_finished
	get_tree().paused = false

	
	
func show_level_completed():
	level_completed.show()
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	if not next_Level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_Level)
	
	

