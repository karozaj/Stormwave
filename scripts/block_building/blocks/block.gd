extends BlockBaseClass

#PLAN JEST TAKI:
#W gridmap ustawiamy tylko bloki których nie da sie zniszczyc
#inne komórki są puste, niewidzialne bez kolizji i jedynie sygnalizują istnienie obiektu lub jego brak
#w danej komórce
#Same bloki są osobnymi scenami, których pozycja jest równa pozycji jeden z komórek gridmapy
#To powinno znacznie ułatwić dynamiczne niszczenie i tworzenie bloków
#Kładzenie bloków będzie zarządzane przez gridmapę, natomiast niszczenie
#przez bloki, które będą notyfikować gridmapę o znisczeniu, a wtedy gridmapa usunie
#informacje o istnieniu obiektu w danej komórce

#function called when a block is damaged by an enemy or by the player's weapons
#also sets transparency of damage overlay material to match the block's condition
func damage(dmg:int,_pos:Vector3):
	durability-=dmg
	$block.material_overlay.albedo_color=Color(1.0,1.0,1.0,1.0-float(durability)/float(max_durability))
	if durability<0:
		destroy_block()
