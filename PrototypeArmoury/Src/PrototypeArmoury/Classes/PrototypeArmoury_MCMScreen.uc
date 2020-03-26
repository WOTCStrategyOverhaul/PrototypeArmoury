class PrototypeArmoury_MCMScreen extends Object config(PrototypeArmoury);

var config int VERSION_CFG;

var localized string ModName;
var localized string PageTitle;
var localized string CanBeChangedInSaveTitle;
var localized string CanNotBeChangedInSaveTitle;

`include(PrototypeArmoury\Src\ModConfigMenuAPI\MCM_API_Includes.uci)

`MCM_API_AutoCheckBoxVars(REMOVE_NICKNAMED_UPGRADES);
`MCM_API_AutoCheckBoxVars(FORCE_LOCK_AND_LOAD);
`MCM_API_AutoCheckBoxVars(ENABLE_TRACE_STARTUP);

`include(PrototypeArmoury\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

`MCM_API_AutoCheckBoxFns(REMOVE_NICKNAMED_UPGRADES, 1);
`MCM_API_AutoCheckBoxFns(FORCE_LOCK_AND_LOAD, 1);
`MCM_API_AutoCheckBoxFns(ENABLE_TRACE_STARTUP, 1);

function OnInit (UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

simulated protected function ClientModCallback (MCM_API_Instance ConfigAPI, int GameMode)
{
	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup Group;

	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage(ModName);
	Page.SetPageTitle(PageTitle);
	Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);

	Group = Page.AddGroup('CanBeChangedInSaveGroup', CanBeChangedInSaveTitle);
	`MCM_API_AutoAddCheckBox(Group, REMOVE_NICKNAMED_UPGRADES);
	
	Group = Page.AddGroup('CanNotBeChangedInSaveGroup', CanNotBeChangedInSaveTitle);
	`MCM_API_AutoAddCheckBox(Group, FORCE_LOCK_AND_LOAD);

	// Not localized on purpose
	Group = Page.AddGroup('DeveloperToolsGroup', "Developer tools");
	ENABLE_TRACE_STARTUP_MCMUI = Group.AddCheckBox('ENABLE_TRACE_STARTUP', "Enable trace on startup", "WARNING: Can flood logs with internal info. WILL reveal things that player is not supposed to be aware of", ENABLE_TRACE_STARTUP, ENABLE_TRACE_STARTUP_SaveHandler);

	Page.ShowSettings();
}

simulated protected function LoadSavedSettings ()
{
	REMOVE_NICKNAMED_UPGRADES = `GETMCMVAR(REMOVE_NICKNAMED_UPGRADES);
	FORCE_LOCK_AND_LOAD = `GETMCMVAR(FORCE_LOCK_AND_LOAD);
	ENABLE_TRACE_STARTUP = `GETMCMVAR(ENABLE_TRACE_STARTUP);
}

simulated protected function ResetButtonClicked (MCM_API_SettingsPage Page)
{
	`MCM_API_AutoReset(REMOVE_NICKNAMED_UPGRADES);
	`MCM_API_AutoReset(FORCE_LOCK_AND_LOAD);
	`MCM_API_AutoReset(ENABLE_TRACE_STARTUP);
}

simulated protected function SaveButtonClicked (MCM_API_SettingsPage Page)
{
	VERSION_CFG = `MCM_CH_GetCompositeVersion();
	SaveConfig();
}
