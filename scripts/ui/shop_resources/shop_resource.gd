extends Resource
class_name ShopResource
## The resource used for the shop menu


## The type of the resource
@export_enum("Ammo","Block","Health") var type:String
## What the resource is called
@export var res_name:String
## The resource description
@export_multiline var description:String
## How much this resource costs
@export var price:int
## How many of the resource the player receives when they buy it
@export var purchasable_number:int
## Maximum amount of resource the player can own
@export var max_number:int
## Image representing the resource
@export var image:Texture2D
## Determines if this resource can be purchased
@export var purchasable:bool=true

var number_owned_by_player:int=0
