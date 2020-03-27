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
	Template.ArmorTechCat = 'conventional';
	Template.ArmorClass = 'basic';
	Template.Tier = 0;
	Template.AkAudioSoldierArmorSwitch = 'Conventional';
	Template.EquipSound = "StrategyUI_Armor_Equip_Conventional";

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, 0, true);

	Template.ArmorCat = 'soldier';

	return Template;
}

static protected function X2DataTemplate CreateTLPPlated ()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLE_PlatedArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_PLT_Support";
	Template.ItemCat = 'armor';
	Template.bAddsUtilitySlot = true;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.TradingPostValue = 20;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('MediumPlatedArmorStats');
	Template.ArmorTechCat = 'plated';
	Template.ArmorClass = 'medium';
	Template.Tier = 1;
	Template.AkAudioSoldierArmorSwitch = 'Predator';
	Template.EquipNarrative = "X2NarrativeMoments.Strategy.CIN_ArmorIntro_PlatedMedium";
	Template.EquipSound = "StrategyUI_Armor_Equip_Plated";

	//Template.CreatorTemplateName = 'MediumPlatedArmor_Schematic'; // The schematic which creates this item
	//Template.BaseItem = 'TLE_KevlarArmor'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_ItemGrantedAbilitySet'.default.MEDIUM_PLATED_HEALTH_BONUS, true);

	Template.ArmorCat = 'soldier';

	return Template;
}

static protected function X2DataTemplate CreateTLPPowered ()
{
	local X2ArmorTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ArmorTemplate', Template, 'TLE_PoweredArmor');
	Template.strImage = "img:///UILibrary_TLE_Common.TLE_Inv_PWR_Support";
	Template.ItemCat = 'armor';
	Template.bAddsUtilitySlot = true;
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.TradingPostValue = 60;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('MediumPoweredArmorStats');
	Template.ArmorTechCat = 'powered';
	Template.ArmorClass = 'medium';
	Template.Tier = 3;
	Template.AkAudioSoldierArmorSwitch = 'Warden';
	Template.EquipNarrative = "X2NarrativeMoments.Strategy.CIN_ArmorIntro_PoweredMedium";
	Template.EquipSound = "StrategyUI_Armor_Equip_Powered";

	//Template.CreatorTemplateName = MediumPoweredArmor_Schematic'; // The schematic which creates this item
	//Template.BaseItem = 'TLE_PlatedArmor'; // Which item this will be upgraded from

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_ItemGrantedAbilitySet'.default.MEDIUM_POWERED_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_ItemGrantedAbilitySet'.default.MEDIUM_POWERED_MITIGATION_AMOUNT);

	Template.ArmorCat = 'soldier';

	return Template;
}

defaultproperties
{
	bShouldCreateDifficultyVariants = true
}