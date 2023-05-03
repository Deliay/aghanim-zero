local Lion =
{
	{
		description = "aghsfort_lion_impale_mana_cost_cooldown",
		ability_name = "aghsfort_lion_impale",
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
		description = "aghsfort_lion_impale_range",
		ability_name = "aghsfort_lion_impale",
		special_values =
		{
			{
				special_value_name = "cast_range",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 120,
			},
			{
				special_value_name = "speed",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 60,
			},
		},
   	},
	{
		 description = "aghsfort_lion_impale_damage",
		 ability_name = "aghsfort_lion_impale",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 80,
	},

	{
		 description = "aghsfort_lion_impale_stun",
		 ability_name = "aghsfort_lion_impale",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.8,
	},

	{
		description = "aghsfort_lion_voodoo_mana_cost_cooldown",
		ability_name = "aghsfort_lion_voodoo",
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
		description = "aghsfort_lion_voodoo_duration",
		ability_name = "aghsfort_lion_voodoo",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
	},

	{
		description = "aghsfort_lion_voodoo_dmg",
		ability_name = "aghsfort_lion_voodoo",
		special_values =
		{
			{
				special_value_name = "int_damage",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 0.5,
			},
			{
				special_value_name = "int_damage_tooltip",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 50,
			},
		},
   	},

	{
		description = "aghsfort_lion_mana_drain_mana_cost_cooldown",
		ability_name = "aghsfort_lion_mana_drain",
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
 		description = "aghsfort_lion_mana_drain_drain",
		 ability_name = "aghsfort_lion_mana_drain",
		 special_value_name = "drain_per_second",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 30,
	},
	{
 		description = "aghsfort_lion_mana_drain_duration",
		 ability_name = "aghsfort_lion_mana_drain",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 1,
	},
	{
 		description = "aghsfort_lion_mana_drain_slow",
		ability_name = "aghsfort_lion_mana_drain",
		special_value_name = "movespeed",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},
	{
		description = "aghsfort_lion_finger_of_death_mana_cost_cooldown",
		ability_name = "aghsfort_lion_finger_of_death",
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
 		description = "aghsfort_lion_finger_of_death_damage",
		 ability_name = "aghsfort_lion_finger_of_death",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 240,
	},
	{
		description = "aghsfort_lion_finger_of_death_layer",
		ability_name = "aghsfort_lion_finger_of_death",
		special_value_name = "damage_per_layer",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 6,
   },
}

return Lion
