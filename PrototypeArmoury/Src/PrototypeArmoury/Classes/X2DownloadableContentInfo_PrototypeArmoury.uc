class X2DownloadableContentInfo_PrototypeArmoury extends X2DownloadableContentInfo;

`include(PrototypeArmoury\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

var config(Engine) bool SuppressTraceLogs;

/////////////////
/// Templates ///
/////////////////

static function OnPreCreateTemplates ()
{
	if (`GETMCMVAR(ENABLE_TRACE_STARTUP))
	{
		GetCDO().SuppressTraceLogs = false;
	}

	class'PATemplateMods'.static.ForceDifficultyVariants();
}

static event OnPostTemplatesCreated ()
{
	class'PATemplateMods'.static.MakeItemsBuildable();
	class'PATemplateMods'.static.ApplyTradingPostModifiers();
	class'PATemplateMods'.static.KillItems();
	
	class'PATemplateMods'.static.AutoConvertItems();
	class'PATemplateMods'.static.OverrideItemCosts();

	class'PATemplateMods'.static.PatchTLPArmorsets();
	class'PATemplateMods'.static.PatchTLPWeapons();
	
	class'PATemplateMods'.static.PatchWeaponTechs();

	if (`GETMCMVAR(FORCE_LOCK_AND_LOAD))
	{
		class'PATemplateMods'.static.DisableLockAndLoadBreakthrough();
	}

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
	if (`GETMCMVAR(FORCE_LOCK_AND_LOAD))
	{
		ForceLockAndLoad(StartState);
	}
}

static event OnLoadedSavedGame ()
{
	if (`GETMCMVAR(FORCE_LOCK_AND_LOAD))
	{
		ForceLockAndLoad(none);
	}
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

///////////////
/// Helpers ///
///////////////

static function X2DownloadableContentInfo_PrototypeArmoury GetCDO ()
{
	return X2DownloadableContentInfo_PrototypeArmoury(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}
