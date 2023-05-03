local Venomancer =
{
	{
		description = "aghsfort2_venomancer_venomous_gale_mana_cost_cooldown",
		ability_name = "aghsfort2_venomancer_venomous_gale",
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
		 description = "aghsfort2_venomancer_venomous_gale_strike_damage",
		 ability_name = "aghsfort2_venomancer_venomous_gale",
		 special_value_name = "strike_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 90,
	},

	{
		 description = "aghsfort2_venomancer_venomous_gale_distance",
		 ability_name = "aghsfort2_venomancer_venomous_gale",
		 special_value_name = "distance",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 120,
	},

	{
		 description = "aghsfort2_venomancer_venomous_gale_tick_damage",
		 ability_name = "aghsfort2_venomancer_venomous_gale",
		 special_value_name = "tick_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 35,
	},

	{
		 description = "aghsfort2_venomancer_poison_sting_damage",
		 ability_name = "aghsfort2_venomancer_poison_sting",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 12,
	},

	{
		 description = "aghsfort2_venomancer_poison_sting_duration",
		 ability_name = "aghsfort2_venomancer_poison_sting",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 3,
	},

	{
		 description = "aghsfort2_venomancer_poison_sting_slow",
		 ability_name = "aghsfort2_venomancer_poison_sting",
		 special_value_name = "movement_speed",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = -6,
	},

	{
		description = "aghsfort2_venomancer_plague_ward_mana_cost_cooldown",
		ability_name = "aghsfort2_venomancer_plague_ward",
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
		 description = "aghsfort2_venomancer_plague_ward_duration",
		 ability_name = "aghsfort2_venomancer_plague_ward",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 8,
		 linked_abilities={
			"aghsfort2_venomancer_chimera_botany"
		},
	},

	{
		 description = "aghsfort2_venomancer_plague_ward_hp",
		 ability_name = "aghsfort2_venomancer_plague_ward",
		 special_value_name = "ward_hp",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 110,
	},

	{
		 description = "aghsfort2_venomancer_plague_ward_damage",
		 ability_name = "aghsfort2_venomancer_plague_ward",
		 special_value_name = "ward_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 18,
	},

	{
		 description = "aghsfort2_venomancer_plague_ward_attack_speed",
		 ability_name = "aghsfort2_venomancer_plague_ward",
		 special_value_name = "ward_as",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 15,
		 linked_abilities={
			"aghsfort2_venomancer_chimera_botany"
		},
	},

	{
		description = "aghsfort2_venomancer_poison_nova_mana_cost_cooldown",
		ability_name = "aghsfort2_venomancer_poison_nova",
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
		 description = "aghsfort2_venomancer_poison_nova_duration",
		 ability_name = "aghsfort2_venomancer_poison_nova",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 3,
	},

	{
		 description = "aghsfort2_venomancer_poison_nova_damage",
		 ability_name = "aghsfort2_venomancer_poison_nova",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 30,
	},

	{
		description = "aghsfort2_venomancer_poison_nova_radius",
		ability_name = "aghsfort2_venomancer_poison_nova",
		special_values =
		{
			{
				special_value_name = "radius",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 125,
			},
			{
				special_value_name = "speed",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 75,
			},
		},
   },

}

return Venomancer