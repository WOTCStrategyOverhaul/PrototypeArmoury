// TODO: X2EventListener_Infiltration::TriggerPrototypeAlert

class X2DownloadableContentInfo_PrototypeArmoury extends X2DownloadableContentInfo;

var config(Engine) bool SuppressTraceLogs;

/////////////////
/// Templates ///
/////////////////

static function OnPreCreateTemplates ()
{
	// If we ever add MCM to this mod, bring this option back
	// But it's not worth adding MCM for one dev option
	/*if (class'UIListener_ModConfigMenu'.default.ENABLE_TRACE_STARTUP)
	{
		GetCDO().SuppressTraceLogs = false;
	}*/

	class'PATemplateMods'.static.ForceDifficultyVariants();
}

static event OnPostTemplatesCreated ()
{
	class'PATemplateMods'.static.MakeItemsBuildable();
	class'PATemplateMods'.static.ApplyTradingPostModifiers();
	class'PATemplateMods'.static.KillItems();
	class'PATemplateMods'.static.OverrideItemCosts();

	class'PATemplateMods'.static.PatchTLPArmorsets();
	class'PATemplateMods'.static.PatchTLPWeapons();
	
	class'PATemplateMods'.static.DisableLockAndLoadBreakthrough();
	class'PATemplateMods'.static.PatchWeaponTechs();

	// TODO: Remove the LockAndLoad card
	// TODO: Config for optional disable of always l&l
	// TODO: UI for weapon upgrade removal

	// These aren't actually template changes, but's this is still a convenient place to do it - before the game fully loads
	PatchUIWeaponUpgradeItem();
}

static protected function PatchUIWeaponUpgradeItem ()
{
	local UIArmory_WeaponUpgradeItem ItemCDO;

	ItemCDO = UIArmory_WeaponUpgradeItem(class'XComEngine'.static.GetClassDefaultObject(class'UIArmory_WeaponUpgradeItem'));
	ItemCDO.bProcessesMouseEvents = false;

	 // UIArmory_WeaponUpgradeItem doesn't need to process input - the BG does it
	 // However, if that flag is set then we don't get mouse events for children
	 // which breaks the "drop item" button
}

///////////////////////
/// Loaded/new game ///
///////////////////////

static event InstallNewCampaign (XComGameState StartState)
{
	ForceLockAndLoad(StartState);
}

static event OnLoadedSavedGame ()
{
	ForceLockAndLoad(none); // TODO: Add a check for XComHQ.bReuseUpgrades != true and call this from OnLoadToStrategy and OnPostExitMissionSequence
}

static protected function ForceLockAndLoad (XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local bool bSubmitLocally;

	if (NewGameState == none)
	{
		bSubmitLocally = true;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("PA: Forcing Lock And Load");
	}

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	XComHQ.bReuseUpgrades = true;

	if(bSubmitLocally)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
}

////////////////
/// Commands ///
////////////////

exec function EnableTrace_PrototypeArmoury (optional bool Enabled = true)
{
	SuppressTraceLogs = !Enabled;
}
