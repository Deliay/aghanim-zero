local DragonKnight =
{
	{
		 description = "aghsfort_dk_breathe_fire_range",
		 ability_name = "aghsfort_dk_breathe_fire",
		 special_value_name = "range",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 150,
	},

	{
		 description = "aghsfort_dk_breathe_fire_reduction",
		 ability_name = "aghsfort_dk_breathe_fire",
		 special_value_name = "reduction",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 5,
	},

	{
		 description = "aghsfort_dk_breathe_fire_duration",
		 ability_name = "aghsfort_dk_breathe_fire",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 2,
	},

	{
		 description = "aghsfort_dk_breathe_fire_damage",
		 ability_name = "aghsfort_dk_breathe_fire",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 75,
	},

	{
		 description = "aghsfort_dk_breathe_fire_pct_cooldown",
		 ability_name = "aghsfort_dk_breathe_fire",
		 special_values =
		 {
			 {
				 special_value_name = "mana_cost",
				 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				 value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			 },
			 {
				 special_value_name = "cooldown",
				 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				 value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			 },
		 },
	},

	---------------------------------------------------------------

	{
		 description = "aghsfort_dk_dragon_tail_stun_duration",
		 ability_name = "aghsfort_dk_dragon_tail",
		 special_value_name = "stun_duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.5,
	},

	{
		 description = "aghsfort_dk_dragon_tail_attack_damage",
		 ability_name = "aghsfort_dk_dragon_tail",
		 special_value_name = "attack_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 12,
	},

	{
		 description = "aghsfort_dk_dragon_tail_radius",
		 ability_name = "aghsfort_dk_dragon_tail",
		 special_value_name = "radius",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 25,
	},

	{
		 description = "aghsfort_dk_dragon_tail_pct_cooldown",
		 ability_name = "aghsfort_dk_dragon_tail",
		 special_values =
		 {
			 {
				 special_value_name = "mana_cost",
				 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				 value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			 },
			 {
				 special_value_name = "cooldown",
				 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				 value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			 },
		 },
	},

	---------------------------------------------------------------

	{
		 description = "aghsfort_dk_dragon_blood_bonus_health_regen",
		 ability_name = "aghsfort_dk_dragon_blood",
		 special_value_name = "bonus_health_regen",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 4,
	},

	{
		 description = "aghsfort_dk_dragon_blood_bonus_armor",
		 ability_name = "aghsfort_dk_dragon_blood",
		 special_value_name = "bonus_armor",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 4,
	},

	------------------------------------------------------------------

	{
		 description = "aghsfort_dk_elder_dragon_form_duration",
		 ability_name = "aghsfort_dk_elder_dragon_form",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 3,
	},

	{
		 description = "aghsfort_dk_elder_dragon_form_bonus_movement_speed",
		 ability_name = "aghsfort_dk_elder_dragon_form",
		 special_value_name = "bonus_movement_speed",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 20,
	},

	{
		 description = "aghsfort_dk_elder_dragon_form_bonus_attack_range",
		 ability_name = "aghsfort_dk_elder_dragon_form",
		 special_value_name = "bonus_attack_range",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},

	{
		 description = "aghsfort_dk_elder_dragon_form_bonus_attack_damage",
		 ability_name = "aghsfort_dk_elder_dragon_form",
		 special_value_name = "bonus_attack_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 20,
	},

	{
		 description = "aghsfort_dk_elder_dragon_form_pct_cooldown",
		 ability_name = "aghsfort_dk_elder_dragon_form",
		 special_values =
		 {
			 {
				 special_value_name = "mana_cost",
				 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				 value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			 },
			 {
				 special_value_name = "cooldown",
				 operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				 value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			 },
		 },
	},

}

return DragonKnight
