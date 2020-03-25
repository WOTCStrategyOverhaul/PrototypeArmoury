class PATemplateMod extends Object abstract;

struct TradingPostValueModifier
{
	var name ItemName;
	var int NewValue;
};

struct ItemCostOverride
{
	var name ItemName;
	var array<int> Difficulties;
	var StrategyCost NewCost;
};

var config(StrategyTuning) array<name> arrDataSetsToForceVariants;

var config(StrategyTuning) array<name> arrMakeItemBuildable;
var config(StrategyTuning) array<name> arrKillItems;
var config(StrategyTuning) array<TradingPostValueModifier> arrTradingPostModifiers;

var config(StrategyTuning) array<name> arrPrototypesToDisable;
var config(StrategyTuning) bool PrototypePrimaries;
var config(StrategyTuning) bool PrototypeSecondaries;
var config(StrategyTuning) bool PrototypeArmorsets;

var config(StrategyTuning) array<ItemCostOverride> arrItemCostOverrides;

static function ForceDifficultyVariants ()
{
	local name DataSetToPatch;
	local X2DataSet DataSetCDO;

	foreach default.arrDataSetsToForceVariants(DataSetToPatch)
	{
		DataSetCDO = X2DataSet(class'XComEngine'.static.GetClassDefaultObjectByName(DataSetToPatch));

		if (DataSetCDO == none)
		{
			`CI_Warn(DataSetToPatch @ "is not a valid X2DataSet class");
		}
		else
		{
			DataSetCDO.bShouldCreateDifficultyVariants = true;
		}
	}
}

static function MakeItemsBuildable ()
{
	local ItemAvaliableImageReplacement ImageReplacement;
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local PAEventListener_UI UIEventListener;
	local X2WeaponTemplate WeaponTemplate;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;
	
	UIEventListener = PAEventListener_UI(class'XComEngine'.static.GetClassDefaultObject(class'PAEventListener_UI'));
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`PA_Log("Making items buildable");

	foreach default.arrMakeItemBuildable(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`CI_Warn(DataTemplate.Name @ "is not an X2ItemTemplate");
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

			`PA_Trace(ItemTemplate.Name @ "was made single-buildable" @ `showvar(ItemTemplate.Requirements.RequiredTechs.Length));
		}
	}
}

static function ApplyTradingPostModifiers ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local TradingPostValueModifier ValueModifier;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.arrTradingPostModifiers(ValueModifier)
	{
		ItemTemplate = ItemTemplateManager.FindItemTemplate(ValueModifier.ItemName);

		ItemTemplate.TradingPostValue = ValueModifier.NewValue;
	}
}

static function KillItems ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local name TemplateName;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`PA_Log("Killing items");

	foreach default.arrKillItems(TemplateName)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficulityVariants);

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate == none)
			{
				`CI_Warn(DataTemplate.Name @ "is not an X2ItemTemplate");
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
}

static function OverrideItemCosts ()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2ItemTemplate ItemTemplate;
	local ItemCostOverride ItemCostOverrideEntry;
	local int TemplateDifficulty;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	`PA_Log("Overriding item costs");

	foreach default.arrItemCostOverrides(ItemCostOverrideEntry)
	{
		DifficulityVariants.Length = 0;
		ItemTemplateManager.FindDataTemplateAllDifficulties(ItemCostOverrideEntry.ItemName, DifficulityVariants);
		
		if (DifficulityVariants.Length == 0)
		{
			`CI_Warn(ItemCostOverrideEntry.ItemName @ "is not an X2ItemTemplate, cannot override cost");
			continue;
		}
		else if (DifficulityVariants.Length == 1 && ItemCostOverrideEntry.Difficulties.Find(3) > -1)
		{
			ItemTemplate = X2ItemTemplate(DifficulityVariants[0]);
			`PA_Trace(ItemTemplate.DataName $ " has had its cost overridden to non-legend values");
			ItemTemplate.Cost = ItemCostOverrideEntry.NewCost;
			continue;
		}

		foreach DifficulityVariants(DataTemplate)
		{
			ItemTemplate = X2ItemTemplate(DataTemplate);

			if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Rookie))
			{
				TemplateDifficulty = 0; // Rookie
			}
			else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Veteran))
			{
				TemplateDifficulty = 1; // Veteran
			}
			else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Commander))
			{
				TemplateDifficulty = 2; // Commander
			}
			else if (ItemTemplate.IsTemplateAvailableToAllAreas(class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Legend))
			{
				TemplateDifficulty = 3; // Legend
			}
			else
			{
				TemplateDifficulty = -1; // Untranslatable Bitfield
			}
			
			if (ItemCostOverrideEntry.Difficulties.Find(TemplateDifficulty) > -1)
			{
				`PA_Trace(ItemTemplate.DataName $ " on difficulty " $ TemplateDifficulty $ " has had its cost overridden");
				ItemTemplate.Cost = ItemCostOverrideEntry.NewCost;
			}
		}
	}
}

///////////
/// TLE ///
///////////

static function PatchTLPArmorsets ()
{
	PatchTLPRanger();
	PatchTLPGrenadier();
	PatchTLPSpecialist();
	PatchTLPSharpshooter();
	PatchTLPPsiOperative();
}

static protected function PatchTLPRanger ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('RangerKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('RangerPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('RangerPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static protected function PatchTLPGrenadier ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('GrenadierKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('GrenadierPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('GrenadierPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static protected function PatchTLPSpecialist ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SpecialistKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SpecialistPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SpecialistPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static protected function PatchTLPSharpshooter ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SharpshooterKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SharpshooterPlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('SharpshooterPoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static protected function PatchTLPPsiOperative ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2ArmorTemplate				Template;
	
	TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('PsiOperativeKevlarArmor'));
	Template.StartingItem = false;
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('PsiOperativePlatedArmor'));
	Template.CreatorTemplateName = 'none';
	Template = X2ArmorTemplate(TemplateManager.FindItemTemplate('PsiOperativePoweredArmor'));
	Template.CreatorTemplateName = 'none';
}

static function PatchTLPWeapons ()
{
	local X2ItemTemplateManager			TemplateManager;
	local X2WeaponTemplate				Template;
	local name							ItemName;
	
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
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties('BreakthroughReuseWeaponUpgrades', DifficulityVariants);
	
	foreach DifficulityVariants(DataTemplate)
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
	if(default.PrototypePrimaries)
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

	if(default.PrototypeSecondaries)
	{
		AddPrototypeItem('MagnetizedWeapons', 'TLE_Pistol_MG');
		AddPrototypeItem('PlasmaRifle', 'TLE_Pistol_BM');
		AddPrototypeItem('AutopsyArchon', 'TLE_Sword_BM');
		AddPrototypeItem('AutopsyAdventStunLancer', 'TLE_Sword_MG');
	}

	if(default.PrototypeArmorsets)
	{
		AddPrototypeItem('PlatedArmor', 'TLE_PlatedArmor');
		AddPrototypeItem('PoweredArmor', 'TLE_PoweredArmor');
	}
}

static protected function AddPrototypeItem (name TechName, name Prototype)
{
	local X2StrategyElementTemplateManager Manager;
	local array<X2DataTemplate> DifficulityVariants;
	local X2DataTemplate DataTemplate;
	local X2TechTemplate TechTemplate;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Manager.FindDataTemplateAllDifficulties(TechName, DifficulityVariants);
	
	foreach DifficulityVariants(DataTemplate)
	{
		TechTemplate = X2TechTemplate(DataTemplate);

		if(TechTemplate != none)
		{
			TechTemplate.ItemRewards.AddItem(Prototype);
		}
	}
}
