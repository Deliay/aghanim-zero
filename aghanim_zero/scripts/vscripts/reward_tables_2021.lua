require( "constants" )

_G.USE_PRICED_REWARDS = true
_G.PRICED_ITEM_GOLD_MIN_PCT = 0.55
_G.PRICED_ITEM_GOLD_MAX_PCT = 1.10
_G.PRICED_ITEM_BONUS_DEPTH_PCT = 0.05
_G.GOLD_REWARD_CHOICE_MIN_PCT = 0.425	-- 1.5 * 0.25
_G.GOLD_REWARD_CHOICE_MAX_PCT = 0.475	-- 1.5 * 0.35
_G.ELITE_VALUE_MODIFIER = 2
_G.ARCANE_FRAGMENT_ELITE_VALUE_MODIFIER = 1.25
_G.ELITE_NEUTRAL_ITEM_VALUE_MODIFIER = 1.25

_G.TRAP_ROOM_COMPLETION_GOLD_REWARD_PCT = 0.1
_G.TRAP_ROOM_NO_DEATH_COMPLETION_GOLD_REWARD_PCT = 0.15
_G.TRAP_ROOM_PERFECT_COMPLETION_GOLD_REWARD_PCT = 0.2

-- Amount of XP earned per hero per depth (if the encounter gives XP)
_G.ENCOUNTER_DEPTH_XP_REWARD =
{
	0,		--1 Starting Room
	900, 	--2,
	1000, 	--3, 
	1100,   --4,  
	1200,   --5, <after this, 4200 total, level 8> 
	400,    --6 Act 1 Boss <after this, 4600 total, level 9> 
	0,   	--7 Transition->Act2, Reward Room  
	1575,  	--8, <level 11, 6175>
	1775,   --9, <level 13, 7950> 
	1975,   --10, <level 14, 9925> 
	2175,   --11, <after this, 12,100 total, level 16>
	1900,   --12 Act 2 Boss <after this, 14010 total, level 17> 
	2700,	--13 Act 3 Reward Room
	3200,   --14
	3500,   --15, 
	6395,   --16,
	0,  	--17 transition room
	0,		--18 Act 3 Boss, gold reward is for items at Bristle only
}

-- Amount of gold earned per hero per depth (if the encounter gives gold)
_G.ENCOUNTER_DEPTH_GOLD_REWARD =
{
	0,	--1 Starting Room
	650, 	--2, 
	775, 	--3, 
	900,    --4,  
	1000,   --5,  
	1000,  	--6 Act 1 Boss README: The boss has a gold bag fountain ability that gives 1000 gold, but gets slammed to 0 at reward time
	2500,	--7 Transition->Act2  ( Note: this gold is not guaranteed )
	1250,  	--8 
	1500,   --9  
	1750,   --10  
	2000,   --11   
	2000,   --12 Act 2 Boss README: The boss has a gold bag fountain ability that gives 2000 gold, but gets slammed to 0 at reward time
	   0,	--13 Act 3 Reward Room [chickens drop loot]
	2300,   --14
	2500,   --15 
	2700,   --16 
	0,  	--17 transition room
	0,		--18 Act 3 Boss, gold reward is for items at Bristle only
}

_G.ENCOUNTER_DEPTH_BATTLE_POINTS =
{
	0, --1
	30, --2
	30,	--3
	30, --4
	30, --5
	60, --6  120
	0, 	--7
	30, --8
	30, --9
	30, --10
	30, --11
	60, --12 240
	0, --13
	30, --14
	30, --15
	30, --16
	0,  --17 transition room
	60, --18 340
}

_G.BATTLE_POINT_DIFFICULTY_MODIFIERS =
{
	1,
	1.1,
	1.2,
	1.3,
	1.4
}

_G.BATTLE_POINT_MIN_DROP_VALUE = 20
_G.BATTLE_POINT_MAX_DROP_VALUE = 40

_G.ARCANE_FRAGMENT_ROOM_CLEAR_VALUE = 0.5
_G.ARCANE_FRAGMENT_DROP_VALUE = 0.5

_G.ARCANE_FRAGMENT_DROP_VALUE_VARIANCE = 0.4

_G.ENCOUNTER_DEPTH_ARCANE_FRAGMENTS =
{
	0, --1
	20, --2
	20,	--3
	20, --4
	20, --5
	40, --6  
	0, 	--7
	22, --8
	22, --9
	22, --10
	22, --11
	44, --12 
	0, --13
	24, --14
	24, --15
	24, --16
	48, --17 
}

_G.ARCANE_FRAGMENT_DIFFICULTY_MODIFIERS =
{
	1,
	1.1,
	1.2,
	1.3,
	1.4
}

_G.ARCANE_FRAGMENT_BP_BONUS_PER_GRANT = 0.1


_G.ARCANE_FRAGMENT_RANDOM_DROP_CHANCES =
{
	{ low_chance =  0, high_chance =  63, num_fragments = 0 },
	{ low_chance = 63, high_chance =  90, num_fragments = 1 },
	{ low_chance = 90, high_chance = 99, num_fragments = 2 },
	{ low_chance = 99, high_chance = 100, num_fragments = 5 },
}

_G.REWARD_TIER_TABLE = 
{
	REWARD_TIER_UPGRADE =
	{
		REWARD_TYPE_ABILITY_UPGRADE = 100,
	},

	REWARD_TIER_MINOR_UPGRADE =
	{
		REWARD_TYPE_MINOR_ABILITY_UPGRADE = 100,
	},
}

_G.ROOM_CHOICE_REWARDS =
{
	REWARD_TYPE_GOLD = 33,
	REWARD_TYPE_EXTRA_LIVES = 33,
	REWARD_TYPE_TREASURE = 33,
}

_G.TREASURE_REWARDS = {}
table.insert( TREASURE_REWARDS, 1, 
	{
	"item_purification_potion",
	"item_ravage_potion",
	"item_echo_slam_potion",
	-- "item_arcanist_potion",
	"item_book_of_strength",
	"item_book_of_agility",
	"item_book_of_intelligence",
	"item_dragon_potion",
} )

table.insert( TREASURE_REWARDS, 2, 
	{
	"item_torrent_effect_potion",
	"item_shadow_wave_effect_potion",
	"item_tome_of_greater_knowledge",
	"item_book_of_greater_strength",
	"item_book_of_greater_agility",
	"item_book_of_greater_intelligence",
	"item_aghsfort_refresher_shard",
})

_G.PRICED_ITEM_REWARD_LIST =
{

	--Tier 1
	--item_mage_loop = 600,
	item_pogo_stick = 600,
	item_chipped_vest = 600,
	item_oblivions_locket = 600,	
	item_precious_egg = 600,
	item_unstable_wand = 600,
	item_longclaws_amulet = 750,
	item_bear_cloak = 750,
	item_winter_embrace = 750,
	item_poor_mans_shield = 750,
	item_mysterious_hat = 750,
	item_possessed_mask = 750,
	item_creed_of_omniscience = 750,
	item_broom_handle = 600,
	item_keen_optic = 600,
	item_ocean_heart = 600,
	item_faded_broach = 600,
	item_arcane_ring = 600,
	
	-- Tier 2
	item_dragon_scale = 1000,
	item_essence_ring = 1000,
	item_bullwhip = 1250,
	item_paw_of_lucius = 1250,
	item_ogre_seal_totem = 1250,
	item_bogduggs_baldric = 1250,
	item_pelt_of_the_old_wolf = 1250,
	item_quicksilver_amulet = 1250,
	item_ice_dragon_maw = 1500,
	item_nether_shawl = 1500,
	item_misericorde = 1500,
	item_ambient_sorcery = 1500,
   	item_vambrace = 1500,
   	item_ring_of_aquila = 1250,
    item_pupils_gift = 1000,
    item_grove_bow = 1250,
	item_craggy_coat = 1250,
    item_imp_claw = 1500,
    item_enchanted_quiver = 1250,
    item_greater_faerie_fire = 1750,

    -- Tier 3
	
	item_vampire_fangs = 2000,
	item_cloak_of_flames = 2500,
	item_sign_of_the_arachnid = 2500,
	item_preserved_skull = 3000,
	item_gravel_foot = 3000,
	item_bogduggs_cudgel = 3000,
	--item_lifestone = 2000,
	item_psychic_headband = 2250,
	item_quickening_charm = 2500,
	item_titan_sliver = 2500,
	item_ceremonial_robe = 2500,
	--item_naginata = 2500,
	item_elven_tunic = 2750,
	
	--item_phoenix_ash = 2500,
	item_orb_of_destruction = 3000,
	item_paladin_sword = 3000,

	-- Tier 4
	item_penta_edged_sword = 3000,
	item_ascetic_cap = 3250,
	item_spy_gadget = 3000,
	item_the_leveller = 3500,
	item_trickster_cloak = 3500,
	item_stormcrafter = 3500,
	item_stony_coat = 3250,
	item_bogduggs_lucky_femur = 3250,
	item_stonework_pendant = 3750,
	item_spell_prism = 4000,
	item_timeless_relic = 4000,
	item_watchers_gaze = 4250,
	item_guardian_shell = 4250,

	item_havoc_hammer = 3000,
    item_witless_shako = 3000,
    item_panic_button = 3000,
    item_minotaur_horn = 3000,
	--item_illusionsts_cape = 3500,
	
	--Tier 5
	item_ex_machina = 4500,
	item_wand_of_the_brine = 4750,
	item_fallen_sky = 4750,
	item_treads_of_ermacor = 5000,
	item_force_boots = 5500,
	item_slippers_of_the_abyss = 5500,
	item_glimmerdark_shield = 5500,
	item_desolator_2 = 6000,
	item_force_field = 6000,
	item_carapace_of_qaldin = 6000,
	--item_giants_ring = 5750,
	item_book_of_shadows = 5500,
	item_apex = 6000,
	--item_mirror_shield = 4750,
	--item_demonicon = 5000,
	
}


_G.PRICED_ITEM_REWARD_LEVEL_LIST =
{

	--Tier 1
	--item_mage_loop = 1,
	item_pogo_stick = 1,
	item_chipped_vest = 1,
	item_oblivions_locket = 1,	
	item_precious_egg = 1,
	item_unstable_wand = 1,
	item_longclaws_amulet = 1,
	item_bear_cloak = 1,
	item_winter_embrace = 1,
	item_poor_mans_shield = 1,
	item_mysterious_hat = 1,
	item_possessed_mask = 1,
	item_creed_of_omniscience = 1,
	item_broom_handle = 1,
	item_keen_optic = 1,
	item_ocean_heart = 1,
	item_faded_broach = 1,
	item_arcane_ring = 1,
	
	-- Tier 2
	item_dragon_scale = 2,
	item_essence_ring = 2,
	item_bullwhip = 2,
	item_paw_of_lucius = 2,
	item_ogre_seal_totem = 2,
	item_bogduggs_baldric = 2,
	item_pelt_of_the_old_wolf = 2,
	item_quicksilver_amulet = 2,
	item_ice_dragon_maw = 2,
	item_nether_shawl = 2,
	item_misericorde = 2,
	item_ambient_sorcery = 2,
	item_vambrace = 2,
	item_ring_of_aquila = 2,
	item_pupils_gift = 2,
	item_grove_bow = 2,
	item_craggy_coat = 2,
	item_imp_claw = 2,
	item_enchanted_quiver = 2,
	item_greater_faerie_fire = 2,

    -- Tier 3
	
	item_vampire_fangs = 3,
	item_cloak_of_flames = 3,
	item_sign_of_the_arachnid = 3,
	item_preserved_skull = 3,
	item_gravel_foot = 3,
	item_bogduggs_cudgel = 3,
	--item_lifestone = 3,
	item_psychic_headband = 3,
	item_quickening_charm = 3,
	item_titan_sliver = 3,
	item_ceremonial_robe = 3,
	--item_naginata = 3,
	item_elven_tunic = 3,
	
	--item_phoenix_ash = 3,
	item_orb_of_destruction = 3,
	item_paladin_sword = 3,

	-- Tier 4
	item_penta_edged_sword = 4,
	item_ascetic_cap = 4,
	item_spy_gadget = 4,
	item_the_leveller = 4,
	item_trickster_cloak = 4,
	item_stormcrafter = 4,
	item_stony_coat = 4,
	item_bogduggs_lucky_femur = 4,
	item_stonework_pendant = 4,
	item_spell_prism = 4,
	item_timeless_relic = 4,
	item_watchers_gaze = 4,
	item_guardian_shell = 4,

	item_havoc_hammer = 4,
	item_witless_shako = 4,
	item_panic_button = 4,
	item_minotaur_horn = 4,
	--item_illusionsts_cape = 4,
	
	--Tier 5
	item_ex_machina = 5,
	item_wand_of_the_brine = 5,
	item_fallen_sky = 5,
	item_treads_of_ermacor = 5,
	item_force_boots = 5,
	item_slippers_of_the_abyss = 5,
	item_glimmerdark_shield = 5,
	item_desolator_2 = 5,
	item_force_field = 5,
	item_carapace_of_qaldin = 5,
	--item_giants_ring = 5,
	item_book_of_shadows = 5,
	item_apex = 5,
	--item_mirror_shield = 5,
	--item_demonicon = 5,
}


_G.ROOM_REWARDS =
{
	-- Act 1
	depth_1 =
	{
		normal = { { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 } }
	},
	depth_2 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_3 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_4 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_5 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},	
	depth_6 = -- Boss
	{
		normal = { { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 } , { REWARD_TIER_UPGRADE = 100 } }
	},
	depth_7 = -- Transition
	{
		normal = { }
	},

	-- Act 2
	depth_8 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_9 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_10 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_11 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_12 = -- Boss
	{
		normal = { { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 } }
	},

	-- Act 3
	depth_13 =
	{
		normal = { },
	},
	depth_14 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_15 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_16 =
	{
		normal = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
		elite  = { { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, { REWARD_TIER_MINOR_UPGRADE = 100 }, },
	},
	depth_17 = -- Boss
	{
		normal = { },	-- No need for rewards, the game is done [or should we put BP rewards in here?]
	},

	depth_20 =
	{
		normal = { { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, }
	},
	
	-- Traps
	traps =
	{
		normal = { { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 }, { REWARD_TIER_UPGRADE = 100 } }
	},	
}
