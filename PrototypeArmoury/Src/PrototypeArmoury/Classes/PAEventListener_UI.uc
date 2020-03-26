class PAEventListener_UI extends X2EventListener config(UI);

// The replacements set directly in config. Will be preferred
var config array<ItemAvaliableImageReplacement> ItemAvaliableImageReplacements;

// Replacements pulled from schematics during OPTC when items are converted to individual build
var array<ItemAvaliableImageReplacement> ItemAvaliableImageReplacementsAutomatic;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateAlertListeners());
	Templates.AddItem(CreateArmoryListeners());

	return Templates;
}

//////////////
/// Alerts ///
//////////////

static function CHEventListenerTemplate CreateAlertListeners ()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'PrototypeArmoury_UI_Alerts');
	Template.AddCHEvent('OverrideImageForItemAvaliable', OverrideImageForItemAvaliable, ELD_Immediate, class'PA_DataStructures'.const.DEFAULT_EVENT_PRIORITY);
	Template.RegisterInStrategy = true;

	return Template;
}

static function EventListenerReturn OverrideImageForItemAvaliable(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local ItemAvaliableImageReplacement Replacement;
	local X2ItemTemplateManager TemplateManager;
	local X2ItemTemplate CurrentItemTemplate, ImageSourceTemplate;
	local XComLWTuple Tuple;
	local int i;

	Tuple = XComLWTuple(EventData);
	if (Tuple == none || Tuple.Id != 'OverrideImageForItemAvaliable') return ELR_NoInterrupt;

	CurrentItemTemplate = X2ItemTemplate(Tuple.Data[1].o);
	
	// Check if we have a manual replacement first
	i = default.ItemAvaliableImageReplacements.Find('TargetItem', CurrentItemTemplate.DataName);
	if (i != INDEX_NONE)
	{
		`PA_Trace("Replacing image for" @ CurrentItemTemplate.DataName @ "with a manually configured option");
		Replacement = default.ItemAvaliableImageReplacements[i];
	}

	// If we don't, check for an automatic one
	else
	{
		i = default.ItemAvaliableImageReplacementsAutomatic.Find('TargetItem', CurrentItemTemplate.DataName);

		if (i != INDEX_NONE)
		{
			`PA_Trace("Replacing image for" @ CurrentItemTemplate.DataName @ "with an automatically generated option");
			Replacement = default.ItemAvaliableImageReplacementsAutomatic[i];
		}
	}
	
	if (i != INDEX_NONE)
	{
		// Found a replacement

		if (Replacement.strImage != "")
		{
			Tuple.Data[0].s = Replacement.strImage;
		}
		else
		{
			TemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
			ImageSourceTemplate = TemplateManager.FindItemTemplate(Replacement.ImageSourceItem);
			
			if (ImageSourceTemplate != none && ImageSourceTemplate.strImage != "")
			{
				Tuple.Data[0].s = ImageSourceTemplate.strImage;
			}
			else
			{
				`PA_Warn(CurrentItemTemplate.DataName @ "has a replacement with image from" @ Replacement.ImageSourceItem @ "but the latter has no image or doesn't exist");
			}
		}
	}

	return ELR_NoInterrupt;
}

//////////////
/// Armory ///
//////////////

static function CHEventListenerTemplate CreateArmoryListeners ()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'PrototypeArmoury_UI_Armory');
	Template.AddCHEvent('UIArmory_WeaponUpgrade_SlotsUpdated', WeaponUpgrade_SlotsUpdated, ELD_Immediate, `PA_DEFAULT_EVENT_PRIORITY);
	Template.AddCHEvent('UIArmory_WeaponUpgrade_NavHelpUpdated', WeaponUpgrade_NavHelpUpdated, ELD_Immediate, `PA_DEFAULT_EVENT_PRIORITY);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn WeaponUpgrade_SlotsUpdated (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIDropWeaponUpgradeButton DropButton;
	local UIArmory_WeaponUpgradeItem Slot;
	local UIList SlotsList;
	local UIPanel Panel;

	// Only if we can reuse upgrades
	if (!`XCOMHQ.bReuseUpgrades) return ELR_NoInterrupt;

	if (`ISCONTROLLERACTIVE)
	{
		// We add the button only if using mouse
		return ELR_NoInterrupt;
	}

	SlotsList = UIList(EventData);
	if (SlotsList == none)
	{
		`RedScreen("Recived UIArmory_WeaponUpgrade_SlotsUpdated but data isn't UIList");
		return ELR_NoInterrupt;
	}

	foreach SlotsList.ItemContainer.ChildPanels(Panel)
	{
		Slot = UIArmory_WeaponUpgradeItem(Panel);
		if (Slot == none || Slot.UpgradeTemplate == none || Slot.bIsDisabled) continue;

		DropButton = Slot.Spawn(class'UIDropWeaponUpgradeButton', Slot);
		DropButton.InitDropButton();
	}

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn WeaponUpgrade_NavHelpUpdated (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local UIArmory_WeaponUpgrade Screen;
	local UINavigationHelp NavHelp;

	// Only if we can reuse upgrades
	if (!`XCOMHQ.bReuseUpgrades) return ELR_NoInterrupt;

	if (!`ISCONTROLLERACTIVE)
	{
		// We add the indicator only if using controller
		return ELR_NoInterrupt;
	}

	Screen = UIArmory_WeaponUpgrade(EventSource);
	NavHelp = UINavigationHelp(EventData);

	if (NavHelp == none)
	{
		`RedScreen("Recived UIArmory_WeaponUpgrade_NavHelpUpdated but data isn't UINavigationHelp");
		return ELR_NoInterrupt;
	}

	if (Screen == none)
	{
		`RedScreen("Recived UIArmory_WeaponUpgrade_NavHelpUpdated but source isn't UIArmory_WeaponUpgrade");
		return ELR_NoInterrupt;
	}

	if (Screen.ActiveList == Screen.SlotsList)
	{
		NavHelp.AddLeftHelp(class'UIUtilities_PA'.default.strDropUpgrade, class'UIUtilities_Input'.const.ICON_X_SQUARE);
	}

	return ELR_NoInterrupt;
}
