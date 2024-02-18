extends Node2D

#drag and press control 
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon
