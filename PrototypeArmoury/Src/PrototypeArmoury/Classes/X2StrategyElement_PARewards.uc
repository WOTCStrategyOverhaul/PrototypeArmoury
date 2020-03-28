class X2StrategyElement_PARewards extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;
	
	// POI rewards
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_PrototypeT2', 'PrototypeT2'));
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_PrototypeT3', 'PrototypeT3'));
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_SidegradeT1', 'SidegradeT1'));
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_SidegradeT2', 'SidegradeT2'));
	Rewards.AddItem(CreateLootTableRewardTemplate('Reward_SidegradeT3', 'SidegradeT3'));

	return Rewards;
}

static function X2DataTemplate CreateLootTableRewardTemplate (name RewardName, name LootTableName)
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, RewardName);
	Template.rewardObjectTemplateName = LootTableName;
	
	Template.GiveRewardFn = GiveLootTableReward;
	Template.GetRewardStringFn = GetLootTableRewardString;

	return Template;
}

static protected function GiveLootTableReward (XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateManager;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2LootTableManager LootManager;
	local LootResults LootToGive;
	local name LootName;
	local int LootIndex, idx;
	local string LootString;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	LootManager = class'X2LootTableManager'.static.GetLootTableManager();
	LootIndex = LootManager.FindGlobalLootCarrier(RewardState.GetMyTemplate().rewardObjectTemplateName);
	if (LootIndex >= 0)
	{
		LootManager.RollForGlobalLootCarrier(LootIndex, LootToGive);
	}
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	// First give each piece of loot to XComHQ so it can be collected and added to LootRecovered, which will stack it automatically
	foreach LootToGive.LootToBeCreated(LootName)
	{
		ItemTemplate = ItemTemplateManager.FindItemTemplate(LootName);
		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		XComHQ.PutItemInInventory(NewGameState, ItemState, true);
	}

	// Then create the loot string for the room
	for (idx = 0; idx < XComHQ.LootRecovered.Length; idx++)
	{
		ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(XComHQ.LootRecovered[idx].ObjectID));

		if (ItemState != none)
		{
			LootString $= ItemState.GetMyTemplate().GetItemFriendlyName() $ " x" $ ItemState.Quantity;

			if (idx < XComHQ.LootRecovered.Length - 1)
			{
				LootString $= ", ";
			}
		}
	}
	RewardState.RewardString = LootString;
	
	// Actually add the loot which was generated to the inventory
	class'XComGameStateContext_StrategyGameRule'.static.AddLootToInventory(NewGameState);
}

static protected function string GetLootTableRewardString (XComGameState_Reward RewardState)
{
	return RewardState.RewardString;
}
