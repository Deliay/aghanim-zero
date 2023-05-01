local Nevermore =
{
	{
		description = "aghsfort_nevermore_shadowraze_cooldown_manacost",
		ability_name = "aghsfort_nevermore_shadowraze1",
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
		linked_abilities={
			"aghsfort_nevermore_shadowraze2",
			"aghsfort_nevermore_shadowraze3"
		},
	},

	{
		 description = "aghsfort_nevermore_shadowraze_damage",
		 ability_name = "aghsfort_nevermore_shadowraze1",
		 special_value_name = "shadowraze_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 75,
		 linked_abilities={
			"aghsfort_nevermore_shadowraze2",
			"aghsfort_nevermore_shadowraze3"
		},
	},

	{
		description = "aghsfort_nevermore_shadowraze_stack",
		ability_name = "aghsfort_nevermore_shadowraze1",
		special_value_name = "stack_bonus_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 30,
		linked_abilities={
		 "aghsfort_nevermore_shadowraze2",
		 "aghsfort_nevermore_shadowraze3"
		},
	},

	{
		description = "aghsfort_nevermore_shadowraze_count",
		ability_name = "aghsfort_nevermore_shadowraze1",
		special_value_name = "max_stacks",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
		int = true,
		linked_abilities={
		 "aghsfort_nevermore_shadowraze2",
		 "aghsfort_nevermore_shadowraze3"
		},
	},

	{
		 description = "aghsfort_nevermore_necromastery_souls",
		 ability_name = "aghsfort_nevermore_necromastery",
		 special_value_name = "max_souls",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 4,
		 int = true,
	},

	{
		 description = "aghsfort_nevermore_necromastery_atk",
		 ability_name = "aghsfort_nevermore_necromastery",
		 special_value_name = "damage_per_soul",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 2,
	},

	{
		 description = "aghsfort_nevermore_necromastery_amp",
		 ability_name = "aghsfort_nevermore_necromastery",
		 special_value_name = "amp_per_soul",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.2,
	},

	{
		description = "aghsfort_nevermore_dark_lord_range",
		ability_name = "aghsfort_nevermore_dark_lord",
		special_value_name = "radius",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 150,
	},

	{
		description = "aghsfort_nevermore_dark_lord_armor",
		ability_name = "aghsfort_nevermore_dark_lord",
		special_value_name = "armor_reduction",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = -2,
	},

	{
		description = "aghsfort_nevermore_dark_lord_duration",
		ability_name = "aghsfort_nevermore_dark_lord",
		special_value_name = "duration",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1.5,
	},

	{
		description = "aghsfort_nevermore_dark_lord_cooldown_manacost",
		ability_name = "aghsfort_nevermore_dark_lord",
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
		description = "aghsfort_nevermore_requiem_duration",
		ability_name = "aghsfort_nevermore_requiem",
		special_values =
		{
			{
				special_value_name = "slow_duration",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 0.4,
			},
			{
				special_value_name = "slow_duration_max",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 1.2,
			},
		},
	},

	{
		description = "aghsfort_nevermore_requiem_range",
		ability_name = "aghsfort_nevermore_requiem",
		special_values =
		{
			{
				special_value_name = "radius",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 200,
			},
			{
				special_value_name = "line_speed",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 140,
			},
		},
	},

	{
		description = "aghsfort_nevermore_requiem_damage",
		ability_name = "aghsfort_nevermore_requiem",
		special_value_name = "soul_damage",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 50,
	},

	{
		description = "aghsfort_nevermore_requiem_cooldown_manacost",
		ability_name = "aghsfort_nevermore_requiem",
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

return Nevermore