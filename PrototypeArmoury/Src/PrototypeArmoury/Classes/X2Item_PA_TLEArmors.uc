class X2Item_PA_TLEArmors extends X2Item;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTLPKevlar());
	Templates.AddItem(CreateTLPPlated());
	Templates.AddItem(CreateTLPPowered());

	return Templates;
}

static protected function X2DataTemplate CreateTLPKevlar ()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLE_KevlarArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_Kevlar_Support";
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.Abilities.AddItem('TLE_KevlarArmorStats');
	Template.ArmorTechCat = 'conventional';
	Template.ArmorClass = 'basic';
	Template.Tier = 0;
	Template.AkAudioSoldierArmorSwitch = 'Conventional';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";
	
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_PA_TLEArmorAbilitySet'.default.TLE_KEVLAR_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_PA_TLEArmorAbilitySet'.default.TLE_KEVLAR_MITIGATION_AMOUNT);

	Template.ArmorCat = 'soldier';

	return Template;
}

static protected function X2DataTemplate CreateTLPPlated ()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLE_PlatedArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_PLT_Support";
	Template.ItemCat = 'armor';
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.TradingPostValue = 20;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('TLE_PlatedArmorStats');
	Template.ArmorTechCat = 'plated';
	Template.ArmorClass = 'medium';
	Template.Tier = 1;
	Template.AkAudioSoldierArmorSwitch = 'Predator';
	Template.EquipNarrative = "X2NarrativeMoments.Strategy.CIN_ArmorIntro_PlatedMedium";
	Template.EquipSound = "StrategyUI_Armor_Equip_Plated";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_PA_TLEArmorAbilitySet'.default.TLE_PLATED_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_PA_TLEArmorAbilitySet'.default.TLE_PLATED_MITIGATION_AMOUNT);

	Template.ArmorCat = 'soldier';

	return Template;
}

static protected function X2DataTemplate CreateTLPPowered ()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLE_PoweredArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_PWR_Support";
	Template.ItemCat = 'armor';
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.TradingPostValue = 60;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('TLE_PoweredArmorStats');
	Template.ArmorTechCat = 'powered';
	Template.ArmorClass = 'medium';
	Template.Tier = 3;
	Template.AkAudioSoldierArmorSwitch = 'Warden';
	Template.EquipNarrative = "X2NarrativeMoments.Strategy.CIN_ArmorIntro_PoweredMedium";
	Template.EquipSound = "StrategyUI_Armor_Equip_Powered";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_PA_TLEArmorAbilitySet'.default.TLE_POWERED_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_PA_TLEArmorAbilitySet'.default.TLE_POWERED_MITIGATION_AMOUNT);

	Template.ArmorCat = 'soldier';

	return Template;
}

defaultproperties
{
	bShouldCreateDifficultyVariants = true
}