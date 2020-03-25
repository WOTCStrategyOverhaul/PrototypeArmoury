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

	class'PATemplateMod'.static.ForceDifficultyVariants();
}

static event OnPostTemplatesCreated ()
{
	class'PATemplateMod'.static.MakeItemsBuildable();
	class'PATemplateMod'.static.ApplyTradingPostModifiers();
	class'PATemplateMod'.static.KillItems();
	class'PATemplateMod'.static.OverrideItemCosts();

	class'PATemplateMod'.static.PatchTLPArmorsets();
	class'PATemplateMod'.static.PatchTLPWeapons();
	
	class'PATemplateMod'.static.DisableLockAndLoadBreakthrough();
	class'PATemplateMod'.static.PatchWeaponTechs();

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

////////////////
/// Commands ///
////////////////

exec function EnableTrace_PrototypeArmoury (optional bool Enabled = true)
{
	SuppressTraceLogs = !Enabled;
}
