local Spirit_Breaker =
{

	{
		description = "aghsfort_spirit_breaker_charge_of_darkness_mana_cost_cooldown",
		ability_name = "aghsfort_spirit_breaker_charge_of_darkness",
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
		description = "aghsfort_spirit_breaker_bulldoze_mana_cost_cooldown",
		ability_name = "aghsfort_spirit_breaker_bulldoze",
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
		description = "aghsfort_spirit_breaker_nether_strike_cost_cooldown",
		ability_name = "aghsfort_spirit_breaker_nether_strike",
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
		description = "aghsfort_spirit_breaker_charge_of_darkness_speed",
		ability_name = "aghsfort_spirit_breaker_charge_of_darkness",
		special_value_name = "movement_speed",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 75,
	},
	{
		description = "aghsfort_spirit_breaker_charge_of_darkness_stun",
		ability_name = "aghsfort_spirit_breaker_charge_of_darkness",
		special_value_name = "stun_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1.2,
	},
	{
		description = "aghsfort_spirit_breaker_charge_of_darkness_radius",
		ability_name = "aghsfort_spirit_breaker_charge_of_darkness",
		special_value_name = "bash_radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 35,
	},	
	{
		description = "aghsfort_spirit_breaker_bulldoze_amp",
		ability_name = "aghsfort_spirit_breaker_bulldoze",
		special_values =
		{
			{
				special_value_name = "movement_speed",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 5,
			},
			{
				special_value_name = "status_resistance",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 2,
			},
		},
	},		
	{
		description = "aghsfort_spirit_breaker_bulldoze_duration",
		ability_name = "aghsfort_spirit_breaker_bulldoze",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1.5,
	},	
	{
		description = "aghsfort_spirit_breaker_greater_bash_damage",
		ability_name = "aghsfort_spirit_breaker_greater_bash",
		special_value_name = "damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 10,
	},			

	{
		description = "aghsfort_spirit_breaker_greater_bash_stun",
		ability_name = "aghsfort_spirit_breaker_greater_bash",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.3,
	},		
	{
		description = "aghsfort_spirit_breaker_greater_bash_chance",
		ability_name = "aghsfort_spirit_breaker_greater_bash",
		special_values =
		{
			{
				special_value_name = "chance_pct",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 4.5,
			},
			{
				special_value_name = "cooldown",
				operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				value = 12,
			},
		},
	},		
	{
		description = "aghsfort_spirit_breaker_greater_bash_knockback",
		ability_name = "aghsfort_spirit_breaker_greater_bash",
		special_value_name = "knockback_distance",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 37,
	},	
	{
		description = "aghsfort_spirit_breaker_nether_strike_damage",
		ability_name = "aghsfort_spirit_breaker_nether_strike",
		special_value_name = "damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 175,
	},
	{
		description = "aghsfort_spirit_breaker_nether_strike_bash",
		ability_name = "aghsfort_spirit_breaker_nether_strike",
		special_value_name = "bash_pct",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.75,
	},
}

return Spirit_Breaker