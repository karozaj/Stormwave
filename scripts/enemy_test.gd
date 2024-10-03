extends StaticBody3D

var health:int=100


func damage(damage_points:int):
	health-=damage_points
	print("enemy damaged ",health)
