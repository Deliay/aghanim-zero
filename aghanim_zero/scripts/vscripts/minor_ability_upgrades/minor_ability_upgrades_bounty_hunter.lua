local BountyHunter =
{

	{
		description = "aghsfort_bounty_hunter_shuriken_toss_mana_cost_cooldown",
		ability_name = "aghsfort_bounty_hunter_shuriken_toss",
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
		description = "aghsfort_bounty_hunter_shuriken_toss_damage",
		ability_name = "aghsfort_bounty_hunter_shuriken_toss",
		special_value_name = "bonus_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},

	{
		description = "aghsfort_bounty_hunter_shuriken_toss_range",
		ability_name = "aghsfort_bounty_hunter_shuriken_toss",
		special_values =
		{
			{
				special_value_name = "range",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 100,
			},
			{
				special_value_name = "speed",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 200,
			},
			{
				special_value_name = "ministun",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 0.4,
			},
		},
	},

	{
		description = "aghsfort_bounty_hunter_jinada_cooldown",
		ability_name = "aghsfort_bounty_hunter_jinada",
		special_value_name = "cooldown",
		operator = MINOR_ABILITY_UPGRADE_OP_MUL,
		value = 12,
	},

	{
		description = "aghsfort_bounty_hunter_jinada_damage",
		ability_name = "aghsfort_bounty_hunter_jinada",
		special_value_name = "bonus_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},

	{
		description = "aghsfort_bounty_hunter_jinada_gold",
		ability_name = "aghsfort_bounty_hunter_jinada",
		special_value_name = "gold_steal",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 16,
	},

	{
		description = "aghsfort_bounty_hunter_wind_walk_mana_cost_cooldown",
		ability_name = "aghsfort_bounty_hunter_wind_walk",
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
		description = "aghsfort_bounty_hunter_wind_walk_armor",
		ability_name = "aghsfort_bounty_hunter_wind_walk",
		special_value_name = "armor_reduction",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 2,
	},

	{
		description = "aghsfort_bounty_hunter_wind_walk_slow",
		ability_name = "aghsfort_bounty_hunter_wind_walk",
		special_value_name = "slow_duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 2,
	},

	{
		description = "aghsfort_bounty_hunter_track_mana_cost_cooldown",
		ability_name = "aghsfort_bounty_hunter_track",
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
		description = "aghsfort_bounty_hunter_track_crit",
		ability_name = "aghsfort_bounty_hunter_track",
		special_values =
		{
			{
				special_value_name = "target_crit_multiplier",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 15,
			},
			{
				special_value_name = "toss_crit_multiplier",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 15,
			},
		},
	},

	{
		description = "aghsfort_bounty_hunter_track_ms",
		ability_name = "aghsfort_bounty_hunter_track",
		special_values =
		{
			{
				special_value_name = "bonus_move_speed_pct",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 8,
			},
			{
				special_value_name = "duration",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 5,
			},
		},
	},

	{
		description = "aghsfort_bounty_hunter_track_gold",
		ability_name = "aghsfort_bounty_hunter_track",
		special_values =
		{
			{
				special_value_name = "bonus_gold_self",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 60,
			},
			{
				special_value_name = "bonus_gold",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 30,
			},
		},
	},

	
}

return BountyHunter
