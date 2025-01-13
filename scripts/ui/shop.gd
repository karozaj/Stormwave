extends Control
class_name ShopMenu
## Shop menu for purchasing blocks and ammo
##
## To be purchasable, a block/weapon needs to have a shop_resource created
## and added to the resource_types array

## Emitted when the start_wave_buttion is pressed
signal start_wave_pressed
## Emitted when the player purchases a resource
signal resource_purchased(res:ShopResource, currency:ShopResource, sender:ShopMenu)

@onready var start_wave_button:Button
@onready var close_button:Button=$CenterContainer/VBoxContainer/HBoxContainer2/ButtonClose
@onready var purchase_button:Button=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/ButtonPurchase
@onready var description_label:Label=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/Description
@onready var cost_label:Label=$CenterContainer/VBoxContainer/HBoxContainer/VBoxInfo/HBoxContainer/Cost
@onready var item_list_owned:ItemList
@onready var item_list_purchase:ItemList=$CenterContainer/VBoxContainer/HBoxContainer/VBoxPurchase/ItemList
## Resources that can be purchased in the shop
@export var resource_types:Array[ShopResource]

##name of the resource used to purchase other resources
@export var currency_name:String="Block"
var currency_index:int
var selected_index:int=-1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused=true
	show()
	Input.mouse_mode=Input.MOUSE_MODE_CONFINED

	for i in resource_types.size():
		item_list_purchase.add_item(resource_types[i].res_name,resource_types[i].image)
		if resource_types[i].res_name==currency_name:
			currency_index=i

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_shop") or Input.is_action_just_pressed("escape"):
		_on_button_close_pressed()

# updates resource numbers visible in the itemlist
func update_player_resource_count(resource_dict:Dictionary):
	for key in resource_dict:
		for i in resource_types.size():
			if resource_types[i].res_name==key:
				resource_types[i].number_owned_by_player=resource_dict[key]
				update_item_text(i)
				break

#updates individual item in item list
func update_item_text(idx:int):
	item_list_purchase.set_item_text(idx,resource_types[idx].res_name+" ("+str(resource_types[idx].number_owned_by_player)+")")


#check if resource can be purchased
func on_item_list_item_selected(index: int) -> void:
	selected_index=index
	description_label.text=resource_types[selected_index].description
	if resource_types[selected_index].purchasable==true:
		cost_label.text=str(resource_types[selected_index].price)+" for "+str(resource_types[selected_index].purchasable_number)
		var player_currency:int=0
		
		for res in resource_types:
			if res.res_name==currency_name:
				player_currency=res.number_owned_by_player
				break
		
		if resource_types[selected_index].price<=player_currency:
			if resource_types[selected_index].number_owned_by_player<resource_types[selected_index].max_number:
				purchase_button.disabled=false
				return
	else:
		cost_label.text="N/A"
	purchase_button.disabled=true


func _on_button_close_pressed() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	get_tree().paused=false
	queue_free()


func _on_button_start_wave_pressed() -> void:
	start_wave_pressed.emit()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	get_tree().paused=false
	queue_free()


func _on_button_purchase_pressed() -> void:
	if selected_index>=0:
		resource_purchased.emit(resource_types[selected_index],resource_types[currency_index],self)
