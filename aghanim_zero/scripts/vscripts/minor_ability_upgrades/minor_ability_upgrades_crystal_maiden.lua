local CrystalMaiden =
{
	{
		description = "aghsfort_rylai_crystal_nova_mana_cost_cooldown",
		ability_name = "aghsfort_rylai_crystal_nova",
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
		description = "aghsfort_rylai_crystal_nova_duration",
		ability_name = "aghsfort_rylai_crystal_nova",
		special_values =
		{
			{
				special_value_name = "duration",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 1,
			},
			{
				special_value_name = "vision_duration",
				operator =  MINOR_ABILITY_UPGRADE_OP_ADD,
				value = 1,
			},
		},
   	},
	{
		 description = "aghsfort_rylai_crystal_nova_damage",
		 ability_name = "aghsfort_rylai_crystal_nova",
		 special_value_name = "nova_damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 75,
	},
	{
		 description = "aghsfort_rylai_crystal_nova_radius",
		 ability_name = "aghsfort_rylai_crystal_nova",
		 special_value_name = "radius",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 50,
	},	
	{
		description = "aghsfort_rylai_crystal_nova_slow",
		ability_name = "aghsfort_rylai_crystal_nova",
		special_values =
		{
			{
				special_value_name = "movespeed_slow",
				operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				value = -5,
			},
			{
				special_value_name = "attackspeed_slow",
				operator =  MINOR_ABILITY_UPGRADE_OP_ADD,
				value = -10,
			},
		},
	},
	{
		description = "aghsfort_rylai_frostbite_mana_cost_cooldown",
		ability_name = "aghsfort_rylai_frostbite",
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
		 description = "aghsfort_rylai_frostbite_dps",
		 ability_name = "aghsfort_rylai_frostbite",
		 special_values =
		 {
			 {
				 special_value_name = "damage_per_second",
				 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 30,
			 },
			 {
				 special_value_name = "creep_damage_per_second",
				 operator =  MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 30,
			 },
		 },
	},
	{
		 description = "aghsfort_rylai_frostbite_duration",
		 ability_name = "aghsfort_rylai_frostbite",
		 special_values =
		 {
			 {
				 special_value_name = "duration",
				 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 0.75,
			 },
			 {
				 special_value_name = "creep_duration",
				 operator =  MINOR_ABILITY_UPGRADE_OP_ADD,
				 value = 0.75,
			 },
		 },
	},
	{
 		description = "aghsfort_rylai_brilliance_aura_mana_regen",
		 ability_name = "aghsfort_rylai_brilliance_aura",
		 special_value_name = "mana_regen",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 1.3,
	},
	{
 		description = "aghsfort_rylai_brilliance_aura_max_stacks",
		 ability_name = "aghsfort_rylai_brilliance_aura",
		 special_value_name = "max_stacks",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 0.5,
		 int = true,
		 elite = true,
	},
	{
		description = "aghsfort_rylai_freezing_field_mana_cost_cooldown",
		ability_name = "aghsfort_rylai_freezing_field",
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
 		description = "aghsfort_rylai_freezing_field_damage",
		 ability_name = "aghsfort_rylai_freezing_field",
		 special_value_name = "damage",
		 operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		 value = 30,
	},
	{
		description = "aghsfort_rylai_freezing_field_duration",
		ability_name = "aghsfort_rylai_freezing_field",
		special_value_name = "channel_time",
		operator = MINOR_ABILITY_UPGRADE_OP_ADD,
		value = 1,
   },
}

return CrystalMaiden
