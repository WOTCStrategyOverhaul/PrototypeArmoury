class PAEventListener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStrategyListeners());

	return Templates;
}

////////////////
/// Strategy ///
////////////////

static function CHEventListenerTemplate CreateStrategyListeners ()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'PrototypeArmoury_Strategy');
	Template.AddCHEvent('OnResearchReport', OnResearchReport, ELD_OnStateSubmitted, `PA_DEFAULT_EVENT_PRIORITY);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn OnResearchReport (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Tech TechState;
	local X2ItemTemplateManager ItemTemplateManager;
	local X2ItemTemplate ItemTemplate;
	local array<name> ItemRewards;
	local name ItemName;
	
	TechState = XComGameState_Tech(EventData);
	if (TechState == none) return ELR_NoInterrupt;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemRewards = TechState.GetMyTemplate().ItemRewards;
	
	foreach ItemRewards(ItemName)
	{
		if (Left(string(ItemName), 4) == "TLE_")
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("PA: Add Prototype Item");
			ItemTemplate = ItemTemplateManager.FindItemTemplate(ItemName);
			class'XComGameState_HeadquartersXCom'.static.GiveItem(NewGameState, ItemTemplate);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

			`HQPRES.UIItemReceived(ItemTemplate);
		}
	}

	return ELR_NoInterrupt;
}
