class PAEventListener_UI extends X2EventListener config(UI);

// The replacements set directly in config. Will be preferred
var config array<ItemAvaliableImageReplacement> ItemAvaliableImageReplacements;

// Replacements pulled from schematics during OPTC when items are converted to individual build
var array<ItemAvaliableImageReplacement> ItemAvaliableImageReplacementsAutomatic;

static function array<X2DataTemplate> CreateTemplates ()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateAlertListeners());

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
