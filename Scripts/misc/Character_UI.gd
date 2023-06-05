extends Control

@onready var character_selector = $VBoxContainer/HSlider

@onready var character_icon = $VBoxContainer/TextureRect
@onready var character_name = $VBoxContainer/n
@onready var character_hp = $VBoxContainer/hp
@onready var character_phres = $VBoxContainer/phpercent
@onready var character_mtres = $VBoxContainer/mtpercent

func _ready():
	character_selector.max_value = (Global.classes.size() - 1)

func get_player() -> Global.p_template:
	return Global.classes[character_selector.value]

func get_player_name() -> String:
	return $VBoxContainer/LineEdit.text
	
func set_values(p: Global.p_template) -> void:
	character_name.text = p.n
	character_hp.text = "points de vie : " + str(p.hp)
	character_phres.value = p.ph_r / 5.0
	character_mtres.value = p.mt_r / 5.0
	character_icon.texture = p.ic
	
func _process(delta):
	set_values(get_player())
