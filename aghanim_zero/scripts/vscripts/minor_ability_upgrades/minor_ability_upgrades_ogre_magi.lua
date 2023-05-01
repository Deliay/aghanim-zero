local OgreMagi =
{
	{
		description = "aghsfort_ogre_magi_fireblast_mana_cost_cooldown",
		ability_name = "aghsfort_ogre_magi_fireblast",
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
			"aghsfort_ogre_magi_unrefined_fireblast",
		},
	},

	{
		 description = "aghsfort_ogre_magi_fireblast_damage",
		 ability_name = "aghsfort_ogre_magi_fireblast",
		 special_value_name = "fireblast_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 60,
		 linked_abilities={
			"aghsfort_ogre_magi_unrefined_fireblast",
		},
	},
	{
		 description = "aghsfort_ogre_magi_fireblast_stun",
		 ability_name = "aghsfort_ogre_magi_fireblast",
		 special_values =
		 {
			 {
				 special_value_name = "cast_range",
				 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 75,
			 },
			 {
				 special_value_name = "stun_duration",
				 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 0.5,
			 },
		 },
		 linked_abilities={
			"aghsfort_ogre_magi_unrefined_fireblast",
		},
	},

	{
		description = "aghsfort_ogre_magi_ignite_mana_cost_cooldown",
		ability_name = "aghsfort_ogre_magi_ignite",
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
		 description = "aghsfort_ogre_magi_ignite_duration",
		 ability_name = "aghsfort_ogre_magi_ignite",
		 special_value_name = "duration",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 2.0,
	},
	{
		 description = "aghsfort_ogre_magi_ignite_slow",
		 ability_name = "aghsfort_ogre_magi_ignite",
		 special_value_name = "slow_movement_speed_pct",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = -10,
	},
	{
		 description = "aghsfort_ogre_magi_ignite_damage",
		 ability_name = "aghsfort_ogre_magi_ignite",
		 special_value_name = "burn_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 25,
	},

	{
		description = "aghsfort_ogre_magi_ignite_targets",
		ability_name = "aghsfort_ogre_magi_ignite",
		special_value_name = "targets",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 0.5,
		int = true,
		elite = true,
   },

	{
		description = "aghsfort_ogre_magi_bloodlust_mana_cost_cooldown",
		ability_name = "aghsfort_ogre_magi_bloodlust",
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
		 description = "aghsfort_ogre_magi_bloodlust_attackspeed",
		 ability_name = "aghsfort_ogre_magi_bloodlust",
		 special_values =
		 {
			 {
				 special_value_name = "bonus_attack_speed",
				 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 30,
			 },
			 {
				 special_value_name = "self_bonus",
				 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 30,
			 },
		 },
	},
	{
		 description = "aghsfort_ogre_magi_bloodlust_movespeed",
		 ability_name = "aghsfort_ogre_magi_bloodlust",
		 special_value_name = "bonus_movement_speed",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 5,
	},

	{
		description = "aghsfort_ogre_magi_multicast_chance",
		ability_name = "aghsfort_ogre_magi_multicast",
		special_values =
		{
			{
				special_value_name = "multicast_2_times",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 5,
			},
			{
				special_value_name = "multicast_3_times",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 6,
			},
			{
				special_value_name = "multicast_4_times",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 7,
			},
			{
				special_value_name = "multicast_5_times",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 5,
			},
		},
	},
}

return OgreMagi