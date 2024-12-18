extends StaticBody3D

#PLAN JEST TAKI:
#W gridmap ustawiamy tylko bloki których nie da sie zniszczyc
#inne komórki są puste, niewidzialne bez kolizji i jedynie sygnalizują istnienie obiektu lub jego brak
#w danej komórce
#Same bloki są osobnymi scenami, których pozycja jest równa pozycji jeden z komórek gridmapy
#To powinno znacznie ułatwić dynamiczne niszczenie i tworzenie bloków
#Kładzenie bloków będzie zarządzane przez gridmapę, natomiast niszczenie
#przez bloki, które będą notyfikować gridmapę o znisczeniu, a wtedy gridmapa usunie
#informacje o istnieniu obiektu w danej komórce

var gridmap:BlockGridMap
	
func destroy_block(world_coordinate):
	if gridmap.destroy_block(world_coordinate)==true:
		call_deferred("queue_free")
		return true
	return false

func damage(dmg:int,_pos:Vector3):
	if dmg>20:
		destroy_block(global_position)


func highlight(world_coordinate)->void:
	gridmap.highlight(world_coordinate)

	

func place_block(world_coordinate)->bool:
	if gridmap.place_block(world_coordinate):
		return true
	else:
		return false
