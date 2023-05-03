local Storm_Spirit =
{

	{
		description = "aghsfort_storm_spirit_static_remnant_cost_cooldown",
		ability_name = "aghsfort_storm_spirit_static_remnant",
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
		description = "aghsfort_storm_spirit_electric_vortex_mana_cost_cooldown",
		ability_name = "aghsfort_storm_spirit_electric_vortex",
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
		description = "aghsfort_storm_spirit_ball_lightning_mana_cost",
		ability_name = "aghsfort_storm_spirit_ball_lightning",
		special_values =
		{
			-- {
			-- 	special_value_name = "mana_cost",
			-- 	operator = MINOR_ABILITY_UPGRADE_OP_MUL,
			-- 	value = MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			-- },
			{
				special_value_name = "ball_lightning_initial_mana_base",
				operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				value = -MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			},
			{
				special_value_name = "ball_lightning_initial_mana_percentage",
				operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				value = -MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			},
			{
				special_value_name = "ball_lightning_travel_cost_base",
				operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				value = -MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			},
			{
				special_value_name = "ball_lightning_travel_cost_percent",
				operator = MINOR_ABILITY_UPGRADE_OP_MUL,
				value = -MINOR_ABILITY_COOLDOWN_MANACOST_PCT,
			},
		},
	},

	{
		description = "aghsfort_storm_spirit_static_remnant_damage",
		ability_name = "aghsfort_storm_spirit_static_remnant",
		special_value_name = "static_remnant_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 60,
	},
	{
		description = "aghsfort_storm_spirit_static_remnant_radius",
		ability_name = "aghsfort_storm_spirit_static_remnant",
		special_values =
		{
			{
				special_value_name = "static_remnant_radius",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 45,
			},
			{
				special_value_name = "static_remnant_damage_radius",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 60,
			},
			{
				special_value_name = "vision_range",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 45,
			},
		},
	},
	{
		description = "aghsfort_storm_spirit_electric_vortex_range",
		ability_name = "aghsfort_storm_spirit_electric_vortex",
		special_values =
		{
			{
				special_value_name = "electric_vortex_pull_distance",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 90,
			},
			{
				special_value_name = "electric_vortex_pull_tether_range",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 90,
			},
			{
				special_value_name = "cast_range",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 90,
			},
		},
	},	
	{
		description = "aghsfort_storm_spirit_electric_vortex_duration",
		ability_name = "aghsfort_storm_spirit_electric_vortex",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.6,
	},		
	{
		description = "aghsfort_storm_spirit_overload_aoe",
		ability_name = "aghsfort_storm_spirit_overload",
		special_value_name = "overload_aoe",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 60,
	},		
	{
		description = "aghsfort_storm_spirit_overload_damage",
		ability_name = "aghsfort_storm_spirit_overload",
		special_value_name = "overload_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 45,
	},	
	{
		description = "aghsfort_storm_spirit_overload_mana",
		ability_name = "aghsfort_storm_spirit_overload",
		special_value_name = "mana_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.5,
	},	
	{
		description = "aghsfort_storm_spirit_overload_slow",
		ability_name = "aghsfort_storm_spirit_overload",
		special_values =
		{
			{
				special_value_name = "overload_attack_slow",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = -30,
			},
			{
				special_value_name = "duration",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 0.6,
			},
		},
	},			

	{
		description = "aghsfort_storm_spirit_ball_lightning_damage",
		ability_name = "aghsfort_storm_spirit_ball_lightning",
		special_value_name = "damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 12,
	},		
	{
		description = "aghsfort_storm_spirit_ball_lightning_aoe",
		ability_name = "aghsfort_storm_spirit_ball_lightning",
		special_values =
		{
			{
				special_value_name = "ball_lightning_aoe",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 50,
			},
			{
				special_value_name = "ball_lightning_vision_radius",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 60,
			},
		},
	},		
}

return Storm_Spirit