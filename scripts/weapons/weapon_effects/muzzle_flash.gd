extends Sprite3D
## Muzzle flash effect used for player weapons

var is_flipped:bool=false

func muzzle_flash_flip():
	if is_flipped:
		flip_h=!flip_h
		is_flipped=false
	else:
		flip_v=!flip_v
		is_flipped=true
