extends Resource
class_name LevelInfo
## The resource used for the level selection menu

## The level scene path
@export var level_scene:String
## A [b]unique[/b] [String] that identifies this level.
## [b]Must[/b] be consistent with the level_identifier in the corresponding [BaseLevel].
## Ideally should be consistent with the level scene file name and be something like "level_1"
@export var level_identifier:String
## The level's name
@export var level_name:String
## The level's description
@export_multiline var level_description:String
## Level image (should be 1:1 aspect ratio)
@export var image:Texture2D
## Can the level be played
@export var playable:bool=true

#the best score reached in this level
var high_score:int
