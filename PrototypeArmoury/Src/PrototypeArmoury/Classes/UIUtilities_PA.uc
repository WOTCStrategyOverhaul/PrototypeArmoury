class UIUtilities_PA extends Object config (UI);

`include(PrototypeArmoury\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

var localized string strDropUpgrade;

var localized string strStripUpgrades;
var localized string strStripUpgradesTooltip;
var localized string strStripUpgradesConfirm;
var localized string strStripUpgradesConfirmDesc;

var config array<EInventorySlot> SlotsToStrip;

////////////////////////////////
/// Removing weapon upgrades ///
////////////////////////////////
// Code "inspired" by BG's RemoveWeaponUpgradesWOTC

static function RemoveWeaponUpgrade (UIArmory_WeaponUpgradeItem Slot)
{
	local UIArmory_WeaponUpgrade UpgradeScreen;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local XComGameState_Item Weapon;

	local XComGameState_Item UpgradeItem;
	local XComGameState_Item NewWeapon;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	local XComGameState ChangeState;
	local array<X2WeaponUpgradeTemplate> EquippedUpgrades;
	local int i;

	UpgradeScreen = UIArmory_WeaponUpgrade(Slot.Screen);
	UpgradeTemplate = Slot.UpgradeTemplate;
	Weapon = Slot.Weapon;

	ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("PA: Remove weapon upgrade");
	ChangeState = `XCOMHISTORY.CreateNewGameState(true, ChangeContainer);
	NewWeapon = XComGameState_Item(ChangeState.ModifyStateObject(class'XComGameState_Item', Weapon.ObjectID));
	EquippedUpgrades = NewWeapon.GetMyWeaponUpgradeTemplates();
	
	for (i = 0; i < EquippedUpgrades.Length; i++)
	{
		if (EquippedUpgrades[i].DataName == UpgradeTemplate.DataName)
		{
			EquippedUpgrades.Remove(i, 1);
			break;
		}
	}
	
	NewWeapon.WipeUpgradeTemplates();
	for (i = 0; i < EquippedUpgrades.Length; i++)
	{
		NewWeapon.ApplyWeaponUpgradeTemplate(EquippedUpgrades[i], i);
	}
	
	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(ChangeState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(ChangeState);
	XComHQ.PutItemInInventory(ChangeState, UpgradeItem);
	
	`GAMERULES.SubmitGameState(ChangeState);

	UpgradeScreen.UpdateSlots();
	UpgradeScreen.WeaponStats.PopulateData(Slot.Weapon);
}

static function OnStripWeaponUpgrades ()
{
	local TDialogueBoxData DialogData;
	local XGParamTag kTag;

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

	if (`GETMCMVAR(REMOVE_NICKNAMED_UPGRADES))
	{
		kTag.StrValue0 = class'UIUtilities_Text'.static.GetColoredText("REMOVED", eUIState_Bad); // TODO: Loc
	}
	else
	{
		kTag.StrValue0 = class'UIUtilities_Text'.static.GetColoredText("PRESERVED", eUIState_Good); // TODO: Loc
	}
	
	DialogData.eType = eDialog_Normal;
	DialogData.strTitle = default.strStripUpgradesConfirm;
	DialogData.strText = `XEXPAND.ExpandString(default.strStripUpgradesConfirmDesc);
	DialogData.fnCallback = OnStripUpgradesDialogCallback;
	DialogData.strAccept = class'UIDialogueBox'.default.m_strDefaultAcceptLabel;
	DialogData.strCancel = class'UIDialogueBox'.default.m_strDefaultCancelLabel;

	`HQPRES.UIRaiseDialog(DialogData);
}

static function OnStripUpgradesDialogCallback (Name eAction)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local array<XComGameState_Unit> Soldiers;
	local XComGameState_Item ItemState, UpgradeItem;
	local int idx;
	local array<X2WeaponUpgradeTemplate> EquippedUpgrades;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local array<StateObjectReference> Inventory;
	local StateObjectReference ItemRef;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XComHQ;	
	local EInventorySlot SlotToStrip;
	local X2EquipmentTemplate EquipmentTemplate;

	if(eAction == 'eUIAction_Accept')
	{
		History = `XCOMHISTORY;
		UpdateState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("PA: Strip Upgrades");
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class' XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(UpdateState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

		Inventory = XComHQ.Inventory;

		foreach Inventory(ItemRef)
		{
			ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ItemRef.ObjectID));
			EquipmentTemplate = X2EquipmentTemplate(ItemState.GetMyTemplate());
			if (EquipmentTemplate != none && ItemState.GetMyTemplate().iItemSize > 0 &&
				default.SlotsToStrip.Find(EquipmentTemplate.InventorySlot) != INDEX_NONE &&
				ItemState.GetNumUpgradeSlots() > 0 && ItemState.HasBeenModified())
			{
				ItemState = XComGameState_Item(UpdateState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
				EquippedUpgrades = ItemState.GetMyWeaponUpgradeTemplates();
				
				if (ShouldRemoveNicknamedUpgrades(ItemState))
				{
					ItemState.WipeUpgradeTemplates();

					foreach EquippedUpgrades(UpgradeTemplate)
					{
						UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(UpdateState);
						XComHQ.PutItemInInventory(UpdateState, UpgradeItem);
					}
				}
				
				if (!ItemState.HasBeenModified() && !ItemState.GetMyTemplate().bAlwaysUnique)
				{
					if (ItemState.GetMyTemplate().bInfiniteItem)
					{
						XComHQ.Inventory.RemoveItem(ItemRef);
					}
				}
			}
		}

		Soldiers = XComHQ.GetSoldiers(true, true);

		for(idx = 0; idx < Soldiers.Length; idx++)
		{
			UnitState = XComGameState_Unit(UpdateState.ModifyStateObject(class'XComGameState_Unit', Soldiers[idx].ObjectID));
			if (UnitState != none)
			{
				foreach default.SlotsToStrip(SlotToStrip)
				{
					ItemState = UnitState.GetItemInSlot(SlotToStrip);
					if (ItemState != none && ItemState.GetNumUpgradeSlots() > 0)
					{
						ItemState = XComGameState_Item(UpdateState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
						EquippedUpgrades = ItemState.GetMyWeaponUpgradeTemplates();

						if (ShouldRemoveNicknamedUpgrades(ItemState))
						{
							ItemState.WipeUpgradeTemplates();

							foreach EquippedUpgrades(UpgradeTemplate)
							{
								UpgradeItem = UpgradeTemplate.CreateInstanceFromTemplate(UpdateState);
								XComHQ.PutItemInInventory(UpdateState, UpgradeItem);
							}
						}
					}
				}
			}
		}

		`GAMERULES.SubmitGameState(UpdateState);
	}
}

static protected function bool ShouldRemoveNicknamedUpgrades (XComGameState_Item ItemState)
{
	if (`GETMCMVAR(REMOVE_NICKNAMED_UPGRADES))
	{
		return true;
	}
	else
	{
		return ItemState.Nickname == "";
	}
}