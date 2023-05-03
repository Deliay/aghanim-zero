local Antimage =
{
	{
		 description = "aghsfort_antimage_mana_break_mana_per_hit",
		 ability_name = "aghsfort_antimage_mana_break",
		 special_value_name = "mana_per_hit",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 20,
	},
	{
		 description = "aghsfort_antimage_mana_break_mana_per_hit_pct",
		 ability_name = "aghsfort_antimage_mana_break",
		 special_value_name = "mana_per_hit_pct",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.7,
	},
	{
		description = "aghsfort_antimage_mana_break_percent_damage_per_burn",
		ability_name = "aghsfort_antimage_mana_break",
		special_value_name = "percent_damage_per_burn",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},
	{
		description = "aghsfort_antimage_mana_break_illusion_percentage",
		ability_name = "aghsfort_antimage_mana_break",
		special_value_name = "illusion_percentage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},


	{
		 description = "aghsfort_antimage_blink_blink_range",
		 ability_name = "aghsfort_antimage_blink",
		 special_value_name = "blink_range",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 200,
	},
	{
		 description = "aghsfort_antimage_blink_mana_cost_cooldown",
		 ability_name = "aghsfort_antimage_blink",
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



	{
		 description = "aghsfort_antimage_counterspell_magic_resistance",
		 ability_name = "aghsfort_antimage_counterspell",
		 special_value_name = "magic_resistance",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 6,
	},
	{
		description = "aghsfort_antimage_counterspell_duration",
		ability_name = "aghsfort_antimage_counterspell",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.4,
	},
	{
		description = "aghsfort_antimage_counterspell_mana_cost_cooldown",
		ability_name = "aghsfort_antimage_counterspell",
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


	{
		 description = "aghsfort_antimage_mana_void_base_damage",
		 ability_name = "aghsfort_antimage_mana_void",
		 special_value_name = "base_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 120,
	},
	{
		description = "aghsfort_antimage_mana_void_ministun",
		ability_name = "aghsfort_antimage_mana_void",
		special_value_name = "ministun",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.6,
   	},
	{
		description = "aghsfort_antimage_mana_void_damage_per_mana",
		ability_name = "aghsfort_antimage_mana_void",
		special_value_name = "damage_per_mana",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.15,
   	},
	{
		description = "aghsfort_antimage_mana_void_aoe_radius",
		ability_name = "aghsfort_antimage_mana_void",
		special_value_name = "aoe_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 100,
   	},
	{
		 description = "aghsfort_antimage_mana_void_mana_cost_cooldown",
		 ability_name = "aghsfort_antimage_mana_void",
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

return Antimage
