extends Node2D

var grabbed_ability: SlotData
var ability_data: ItemData

signal show_range(ability_data: AbilityData)
signal ability_confirm()

# on ability used
# show range (toggleable)
func on_ability_used(ability_datas: InventoryData, index: int) -> void:
	grabbed_ability = ability_datas.grab_ability_data(index)
	ability_data = grabbed_ability.item_data
	match [ability_data.ability_type]:
		["RangedAOE"]:
			show_range.emit(ability_data)
	
			#create_spell(spell_pos, grabbed_spell_data)

			

	
#var ranged_st_spell = preload('res://scenes/spells/ranged_single_target.tscn')
#func create_spell(pos, spell_data: SpellData):
	#var _spell = ranged_st_spell.instantiate()
	#_spell.spell_data = spell_data
	#_spell.position = pos
	#$Spells.add_child(_spell)
