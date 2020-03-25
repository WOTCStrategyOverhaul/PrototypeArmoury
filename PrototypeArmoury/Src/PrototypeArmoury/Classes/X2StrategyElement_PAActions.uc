//---------------------------------------------------------------------------------------
//  AUTHOR:  NotSoLoneWolf
//  PURPOSE: This class contains all the non-activity Covert Action
//           templates required for the mod
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class X2StrategyElement_PAActions extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;
	
	CovertActions.AddItem(CreateExperimentalItemTemplate());
	
	return CovertActions;
}

static function X2DataTemplate CreateExperimentalItemTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'CovertAction_ExperimentalItem');

	Template.ChooseLocationFn = class'X2StrategyElement_DefaultCovertActions'.static.ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem('CovertActionNarrative_ExperimentalItem_Skirmishers');
	Template.Narratives.AddItem('CovertActionNarrative_ExperimentalItem_Reapers');
	Template.Narratives.AddItem('CovertActionNarrative_ExperimentalItem_Templars');

	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));
	
	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');
	Template.Risks.AddItem('CovertActionRisk_SoldierCaptured');
	Template.Risks.AddItem('CovertActionRisk_Ambush');

	Template.Rewards.AddItem('Reward_ExperimentalItem');

	return Template;
}

/////////////////
//   Helpers   //
/////////////////

private static function CovertActionSlot CreateDefaultSoldierSlot (name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass, optional bool bPromotionAllowed = false)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHP');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostAim');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostMobility');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostDodge');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostWill');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHacking');
	if (bPromotionAllowed) SoldierSlot.Rewards.AddItem('Reward_RankUp');

	SoldierSlot.iMinRank = iMinRank;
	SoldierSlot.bChanceFame = false;
	SoldierSlot.bRandomClass = bRandomClass;
	SoldierSlot.bFactionClass = bFactionClass;

	if (SlotName == 'CovertActionRookieStaffSlot')
	{
		SoldierSlot.bChanceFame = false;
	}

	return SoldierSlot;
}

private static function CovertActionSlot CreateDefaultStaffSlot(name SlotName)
{
	local CovertActionSlot StaffSlot;
	
	// Same as Soldier Slot, but no rewards
	StaffSlot.StaffSlot = SlotName;
	StaffSlot.bReduceRisk = false;
	
	return StaffSlot;
}

private static function CovertActionSlot CreateDefaultOptionalSlot(name SlotName, optional int iMinRank, optional bool bFactionClass, optional bool bReduceRisk)
{
	local CovertActionSlot OptionalSlot;

	OptionalSlot.StaffSlot = SlotName;
	OptionalSlot.bChanceFame = false;
	OptionalSlot.bReduceRisk = bReduceRisk;
	OptionalSlot.iMinRank = iMinRank;
	OptionalSlot.bFactionClass = bFactionClass;

	return OptionalSlot;
}

private static function StrategyCostReward CreateOptionalCostSlot(name ResourceName, int Quantity)
{
	local StrategyCostReward ActionCost;
	local ArtifactCost Resources;

	Resources.ItemTemplateName = ResourceName;
	Resources.Quantity = Quantity;
	ActionCost.Cost.ResourceCosts.AddItem(Resources);
	ActionCost.Reward = 'Reward_DecreaseRisk';
	
	return ActionCost;
}

private static function CovertActionSlot CreateDefaultPromotionSlot(name SlotName)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_RankUp');

	return SoldierSlot;
}