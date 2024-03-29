class PATemplateMods extends Object abstract config(StrategyTuning);

var config array<ItemFromDLC> arrDataSetsToForceVariants;
var config array<ItemFromDLC> arrMakeItemBuildable;
var config array<ItemFromDLC> arrKillItems;
var config array<TradingPostValueModifier> arrTradingPostModifiers;

var config array<StrategyCostScalar> ResourceCostScalars;
var config array<StrategyCostScalar> ArtifactCostScalars;

var config array<StrategyCostScalar> ResourceCostScalars_CI;
var config array<StrategyCostScalar> ArtifactCostScalars_CI;

var config array<name> arrPrototypesToDisable;
var config array<name> arrTLPArmorsToHide;

var config bool RESEARCH_GRANTS_PRIMARY;
var config bool RESEARCH_GRANTS_SECONDARY;
var config bool RESEARCH_GRANTS_ARMORSET;

var config array<ItemCostOverride> arrItemCostOverrides;

var config array<AutoItemConversion> arrAutoConvertItem;
var config float AutoBlackMarketPriceMult;

static function ForceDifficultyVariants ()
{
	local ItemFromDLC DataSetToPatch;
	local X2DataSet DataSetCDO;

	foreach default.arrDataSetsToForceVariants(DataSetToPatch)
	{
		if (!class'PAHelpers'.static.IsDLCLoaded(DataSetToPatch.DLC))
			continue;

		DataSetCDO = X2DataSet(class'XComEngine'.static.GetClassDefaultObjectByName(DataSetToPatch.ItemName));

		if (DataSetCDO == none)
		{
			`PA_WarnNoStack(DataSetToPatch.ItemName @ "is not a valid X2DataSet class");
		}
		else
		{
			DataSetCDO.bShouldCreateDifficultyVariants = true;
		}
	}
}

static function MakeItemsBuildable ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local PAEventListener_UI UIEventListener;
	local ItemFromDLC TemplateItem;

	UIEventListener = PAEventListener_UI(class'XComEngine'.static.GetClassDefaultObject(class'PAEventListener_UI'));
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`PA_Log("Making" @ default.arrMakeItemBuildable.Length @ "items buildable");

	foreach default.arrMakeItemBuildable(TemplateItem)
	{
		if (!class'PAHelpers'.static.IsDLCLoaded(TemplateItem.DLC))
			continue;

		MakeItemBuildable(TemplateItem.ItemName, ItemTemplateManager, UIEventListener);
	}
}

static function MakeItemBuildable (name TemplateName, X2ItemTemplateManager ItemTemplateManager, PAEventListener_UI UIEventListener)
{
	local ItemAvaliableImageReplacement ImageReplacement;
	local array<X2DataTemplate> DifficultyVariants;
	local X2WeaponTemplate WeaponTemplate;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;

	ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficultyVariants);
	
	`PA_Trace("Evaluating" @ TemplateName);

	foreach DifficultyVariants(DataTemplate)
	{
		ItemTemplate = X2ItemTemplate(DataTemplate);

		if (ItemTemplate == none)
		{
			`PA_WarnNoStack(DataTemplate.Name @ "is not an X2ItemTemplate");
			continue;
		}

		// Check if we need to replace the image on "ItemAvaliable" screen
		// Do this before we nuke the schematic ref
		WeaponTemplate = X2WeaponTemplate(ItemTemplate);
		if (
			// If this item/weapon has attachments
			WeaponTemplate != none && WeaponTemplate.DefaultAttachments.Length > 0

			// And it has a creator schematic (although it should, otherwise why is it in this code at all?)
			&& ItemTemplate.CreatorTemplateName != ''

			// And we haven't added the replacement already (due to difficulty variants)
			&& UIEventListener.ItemAvaliableImageReplacementsAutomatic.Find('TargetItem', ItemTemplate.DataName) == INDEX_NONE
		)
		{
			ImageReplacement.TargetItem = ItemTemplate.DataName;
			ImageReplacement.ImageSourceItem = ItemTemplate.CreatorTemplateName;

			UIEventListener.ItemAvaliableImageReplacementsAutomatic.AddItem(ImageReplacement);
			`PA_Trace("Added image replacement for" @ ItemTemplate.DataName);
		}

		ItemTemplate.CanBeBuilt = true;
		ItemTemplate.bInfiniteItem = false;
		ItemTemplate.CreatorTemplateName = '';
		
		AdjustItemCost(ItemTemplate, GetTemplateDifficulty(ItemTemplate));

		`PA_Trace(ItemTemplate.Name @ "was made single-buildable" @ `showvar(ItemTemplate.Requirements.RequiredTechs.Length));
	}
}

static function ApplyTradingPostModifiers ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local TradingPostValueModifier ValueModifier;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrTradingPostModifiers(ValueModifier)
	{
		if (!class'PAHelpers'.static.IsDLCLoaded(ValueModifier.DLC))
			continue;

		ApplyTradingPostModifier(ValueModifier, ItemTemplateManager);
	}
}

static function ApplyTradingPostModifier (TradingPostValueModifier ValueModifier, X2ItemTemplateManager ItemTemplateManager)
{
	local X2ItemTemplate ItemTemplate;

	ItemTemplate = ItemTemplateManager.FindItemTemplate(ValueModifier.ItemName);
	ItemTemplate.TradingPostValue = ValueModifier.NewValue;
}

static function KillItems ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local ItemFromDLC TemplateItem;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`PA_Log("Killing items");

	foreach default.arrKillItems(TemplateItem)
	{
		if (!class'PAHelpers'.static.IsDLCLoaded(TemplateItem.DLC))
			continue;

		KillItem(TemplateItem.ItemName, ItemTemplateManager);
	}
}

static function KillItem (name TemplateName, X2ItemTemplateManager ItemTemplateManager)
{
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;

	ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficultyVariants);

	foreach DifficultyVariants(DataTemplate)
	{
		ItemTemplate = X2ItemTemplate(DataTemplate);

		if (ItemTemplate == none)
		{
			`PA_WarnNoStack(DataTemplate.Name @ "is not an X2ItemTemplate");
			continue;
		}

		// "Killing" inspired by LW2
		ItemTemplate.CanBeBuilt = false;
		ItemTemplate.PointsToComplete = 999999;
		ItemTemplate.Requirements.RequiredEngineeringScore = 999999;
		ItemTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
		ItemTemplate.OnBuiltFn = none;
		ItemTemplate.Cost.ResourceCosts.Length = 0;
		ItemTemplate.Cost.ArtifactCosts.Length = 0;

		`PA_Trace(ItemTemplate.Name @ "was killed");
	}
}

static function AutoConvertItems ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local PAEventListener_UI UIEventListener;
	local AutoItemConversion ConversionEntry;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;
	local ArtifactCost Cost;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	UIEventListener = PAEventListener_UI(class'XComEngine'.static.GetClassDefaultObject(class'PAEventListener_UI'));

	foreach default.arrAutoConvertItem(ConversionEntry)
	{
		if (!class'PAHelpers'.static.IsDLCLoaded(ConversionEntry.DLC))
			continue;

		TemplateName = ConversionEntry.ItemName;
		ItemTemplate = ItemTemplateManager.FindItemTemplate(TemplateName);
		
		`PA_Log("Autoconverting: " $ TemplateName);

		if (ItemTemplate == none)
		{
			`PA_WarnNoStack(TemplateName @ "is not an X2ItemTemplate");
			continue;
		}

		CopyItemRequirements(ItemTemplate, ItemTemplateManager);
		KillItem(ItemTemplate.CreatorTemplateName, ItemTemplateManager);
		MakeItemBuildable(TemplateName, ItemTemplateManager, UIEventListener);

		ItemTemplate.TradingPostValue = int(default.AutoBlackMarketPriceMult * ConversionEntry.Supplies);

		ItemTemplate.Cost.ResourceCosts.Length = 0;
		ItemTemplate.Cost.ArtifactCosts.Length = 0;
		
		if (ConversionEntry.Supplies > 0)
		{
			Cost.ItemTemplateName = 'Supplies';
			Cost.Quantity = ConversionEntry.Supplies;
			ItemTemplate.Cost.ResourceCosts.AddItem(Cost);
		}
		
		if (ConversionEntry.Alloys > 0)
		{
			Cost.ItemTemplateName = 'AlienAlloy';
			Cost.Quantity = ConversionEntry.Alloys;
			ItemTemplate.Cost.ResourceCosts.AddItem(Cost);
		}
		
		if (ConversionEntry.Elerium > 0)
		{
			Cost.ItemTemplateName = 'EleriumDust';
			Cost.Quantity = ConversionEntry.Elerium;
			ItemTemplate.Cost.ResourceCosts.AddItem(Cost);
		}
	}
}

static function CopyItemRequirements (X2ItemTemplate ItemTemplate, X2ItemTemplateManager ItemTemplateManager)
{
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate SchematicTemplate;
	
	ItemTemplateManager.FindDataTemplateAllDifficulties(ItemTemplate.CreatorTemplateName, DifficultyVariants);

	foreach DifficultyVariants(DataTemplate)
	{
		SchematicTemplate = X2ItemTemplate(DataTemplate);

		if (SchematicTemplate == none)
		{
			`PA_WarnNoStack(DataTemplate.Name @ "is not an X2ItemTemplate");
			continue;
		}

		ItemTemplate.Requirements = SchematicTemplate.Requirements;
	}
}

static function OverrideItemCosts ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local ItemCostOverride ItemCostOverrideEntry;
	local int TemplateDifficulty;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`PA_Log("Overriding item costs");

	foreach default.arrItemCostOverrides(ItemCostOverrideEntry)
	{
		if (!class'PAHelpers'.static.IsDLCLoaded(ItemCostOverrideEntry.DLC))
			continue;

		DifficultyVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(ItemCostOverrideEntry.ItemName, DifficultyVariants);
		
		if (DifficultyVariants.Length == 0)
		{
			`PA_WarnNoStack(ItemCostOverrideEntry.ItemName @ "is not an X2ItemTemplate, cannot override cost");
			continue;
		}
		else if (DifficultyVariants.Length == 1 && ItemCostOverrideEntry.Difficulties.Find(3) > -1)
		{
			ItemTemplate = X2ItemTemplate(DifficultyVariants[0]);
			`PA_Trace(ItemTemplate.DataName $ " has had its cost overridden to non-legend values");
			ItemTemplate.Cost = ItemCostOverrideEntry.NewCost;
			
			continue;
		}

		foreach DifficultyVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			TemplateDifficulty = GetTemplateDifficulty(ItemTemplate);
			
			if (ItemCostOverrideEntry.Difficulties.Find(TemplateDifficulty) > -1)
			{
				`PA_Trace(ItemTemplate.DataName $ " on difficulty " $ TemplateDifficulty $ " has had its cost overridden");
				
				ItemTemplate.Cost = ItemCostOverrideEntry.NewCost;

				if (ItemCostOverrideEntry.bApplyCostScalars) AdjustItemCost(ItemTemplate, TemplateDifficulty);
			}
		}
	}
}

static function AdjustItemCost (X2ItemTemplate ItemTemplate, int TemplateDifficulty)
{
	local array<StrategyCostScalar> ResourceMultipliers, ArtifactMultipliers;
	local StrategyCostScalar CostScalar;
	local int i;

	if (TemplateDifficulty < 0)
	{
		`PA_Trace("Cannot adjust cost - invalid difficulty");
		return;
	}

	if (class'PAHelpers'.static.IsDLCLoaded('CovertInfiltration'))
	{
		`PA_Trace("Covert Infiltration Detected!");
		ResourceMultipliers = default.ResourceCostScalars_CI;
		ArtifactMultipliers = default.ArtifactCostScalars_CI;
	}
	else
	{
		`PA_Trace("Covert Infiltration Missing!");
		ResourceMultipliers = default.ResourceCostScalars;
		ArtifactMultipliers = default.ArtifactCostScalars;
	}
	
	`PA_Trace("Adjusting item cost of " $ ItemTemplate.DataName $ " on difficulty " $ TemplateDifficulty);

	for (i = 0; i < ItemTemplate.Cost.ResourceCosts.Length; i++)
	{
		foreach ResourceMultipliers(CostScalar)
		{
			if (ItemTemplate.Cost.ResourceCosts[i].ItemTemplateName == CostScalar.ItemTemplateName && TemplateDifficulty == CostScalar.Difficulty)
			{
				`PA_Trace("--> " $ CostScalar.ItemTemplateName $ ": " $ CostScalar.Scalar);
				ItemTemplate.Cost.ResourceCosts[i].Quantity = Round(ItemTemplate.Cost.ResourceCosts[i].Quantity * CostScalar.Scalar);
			}
		}
	}

	for (i = 0; i < ItemTemplate.Cost.ArtifactCosts.Length; i++)
	{
		foreach ArtifactMultipliers(CostScalar)
		{
			if ((ItemTemplate.Cost.ArtifactCosts[i].ItemTemplateName == CostScalar.ItemTemplateName || CostScalar.ItemTemplateName == 'AllArtifacts') && TemplateDifficulty == CostScalar.Difficulty)
			{
				`PA_Trace("--> " $ ItemTemplate.Cost.ArtifactCosts[i].ItemTemplateName $ ": " $ CostScalar.Scalar);
				ItemTemplate.Cost.ArtifactCosts[i].Quantity = Round(ItemTemplate.Cost.ArtifactCosts[i].Quantity * CostScalar.Scalar);
			}
		}
	}
}

static function int GetTemplateDifficulty (X2ItemTemplate ItemTemplate)
{
	if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Rookie))
	{
		return 0; // Rookie
	}
	else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Veteran))
	{
		return 1; // Veteran
	}
	else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Commander))
	{
		return 2; // Commander
	}
	else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Legend))
	{
		return 3; // Legend
	}
	else
	{
		return -1; // Untranslatable Bitfield
	}
}

///////////
/// TLE ///
///////////

static function PatchTLPArmorsets ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	local name							ItemName;

	if (!class'PAHelpers'.static.IsDLCLoaded('TLE'))
		return;
		
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrTLPArmorsToHide(ItemName)
	{
		Template = X2ArmorTemplate(TemplateManager.FindItemTemplate(name(ItemName $ 'KevlarArmor')));
		if (Template != none) Template.StartingItem = false;

		Template = X2ArmorTemplate(TemplateManager.FindItemTemplate(name(ItemName $ 'PlatedArmor')));
		if (Template != none) Template.CreatorTemplateName = 'none';

		Template = X2ArmorTemplate(TemplateManager.FindItemTemplate(name(ItemName $ 'PoweredArmor')));
		if (Template != none) Template.CreatorTemplateName = 'none';
	}
}

static function PatchTLPWeapons ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2WeaponTemplate				Template;
	local name							ItemName;
	
	if (!class'PAHelpers'.static.IsDLCLoaded('TLE'))
		return;

	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrPrototypesToDisable(ItemName)
	{
		Template = X2WeaponTemplate(TemplateManager.FindItemTemplate(name(ItemName $ '_MG')));
		if(Template != none)
		{
			Template.CreatorTemplateName = 'none';
		}
		Template = X2WeaponTemplate(TemplateManager.FindItemTemplate(name(ItemName $ '_BM')));
		if(Template != none)
		{
			Template.CreatorTemplateName = 'none';
		}
	}
}

////////////////
/// Research ///
////////////////

static function DisableLockAndLoadBreakthrough ()
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties('BreakthroughReuseWeaponUpgrades', DifficultyVariants);
	
	foreach DifficultyVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if (TechTemplate != none)
		{
			TechTemplate.bBreakthrough = false;
			TechTemplate.Requirements.RequiredScienceScore = 999999;
			TechTemplate.Requirements.bVisibleifPersonnelGatesNotMet = false;
			TechTemplate.Requirements.SpecialRequirementsFn = ReturnFalse;
		}
	}
}

static protected function bool ReturnFalse ()
{
	return false;
}

static function PatchWeaponTechs ()
{
	if (!class'PAHelpers'.static.IsDLCLoaded('TLE'))
		return;

	if(default.RESEARCH_GRANTS_PRIMARY)
	{
		AddPrototypeItem('MagnetizedWeapons', 'TLE_AssaultRifle_MG');
		AddPrototypeItem('PlasmaRifle', 'TLE_AssaultRifle_BM');
		AddPrototypeItem('MagnetizedWeapons', 'TLE_Shotgun_MG');
		AddPrototypeItem('AlloyCannon', 'TLE_Shotgun_BM');
		AddPrototypeItem('GaussWeapons', 'TLE_SniperRifle_MG');
		AddPrototypeItem('PlasmaSniper', 'TLE_SniperRifle_BM');
		AddPrototypeItem('GaussWeapons', 'TLE_Cannon_MG');
		AddPrototypeItem('HeavyPlasma', 'TLE_Cannon_BM');
	}

	if(default.RESEARCH_GRANTS_SECONDARY)
	{
		AddPrototypeItem('MagnetizedWeapons', 'TLE_Pistol_MG');
		AddPrototypeItem('PlasmaRifle', 'TLE_Pistol_BM');
		AddPrototypeItem('AutopsyArchon', 'TLE_Sword_BM');
		AddPrototypeItem('AutopsyAdventStunLancer', 'TLE_Sword_MG');
	}

	if(default.RESEARCH_GRANTS_ARMORSET)
	{
		AddPrototypeItem('PlatedArmor', 'TLE_PlatedArmor');
		AddPrototypeItem('PoweredArmor', 'TLE_PoweredArmor');
	}
}

static protected function AddPrototypeItem (name TechName, name Prototype)
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficultyVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties(TechName, DifficultyVariants);
	
	foreach DifficultyVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if(TechTemplate != none)
		{
			TechTemplate.ItemRewards.AddItem(Prototype);
		}
	}
}
