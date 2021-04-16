class X2StrategyElement_PAPointsOfInterest extends X2StrategyElement config(GameCore);

var config bool PROTOTYPE_SCANSITES;
var config bool SIDEGRADE_SCANSITES;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreatePOIPrototypeT2Template());
	Templates.AddItem(CreatePOIPrototypeT3Template());
	Templates.AddItem(CreatePOISidegradeT1Template());
	Templates.AddItem(CreatePOISidegradeT2Template());
	Templates.AddItem(CreatePOISidegradeT3Template());

	return Templates;
}

//---------------------------------------------------------------------------------------

static function X2DataTemplate CreatePOIPrototypeT2Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Prototype_T2');

	Template.CanAppearFn = HasNoTier2_Prototype;

	return Template;
}

static function X2DataTemplate CreatePOIPrototypeT3Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Prototype_T3');

	Template.CanAppearFn = HasAllTier2_Prototype;

	return Template;
}

static function X2DataTemplate CreatePOISidegradeT1Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Sidegrade_T1');

	Template.CanAppearFn = HasNoTier2_Sidegrade;

	return Template;
}

static function X2DataTemplate CreatePOISidegradeT2Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Sidegrade_T2');

	Template.CanAppearFn = HasSomeTier2_Sidegrade;

	return Template;
}

static function X2DataTemplate CreatePOISidegradeT3Template()
{
	local X2PointOfInterestTemplate Template;

	`CREATE_X2POINTOFINTEREST_TEMPLATE(Template, 'POI_Sidegrade_T3');

	Template.CanAppearFn = HasAllTier3_Sidegrade;

	return Template;
}

//----------------------------------------------------------------------

static function bool HasNoTier2_Prototype(XComGameState_PointOfInterest POIState)
{
	return (default.PROTOTYPE_SCANSITES
		 && `XCOMHQ.IsTechResearched('MagnetizedWeapons') == false
		 && `XCOMHQ.IsTechResearched('PlatedArmor') == false
	);
}

static function bool HasAllTier2_Prototype(XComGameState_PointOfInterest POIState)
{
	return (default.PROTOTYPE_SCANSITES
		 && `XCOMHQ.IsTechResearched('MagnetizedWeapons')
		 && `XCOMHQ.IsTechResearched('GaussWeapons')
		 && `XCOMHQ.IsTechResearched('PlatedArmor')
	);
}

static function bool HasNoTier2_Sidegrade(XComGameState_PointOfInterest POIState)
{
	return (default.SIDEGRADE_SCANSITES
		 && `XCOMHQ.IsTechResearched('MagnetizedWeapons') == false
		 && `XCOMHQ.IsTechResearched('PlatedArmor') == false
	);
}

static function bool HasSomeTier2_Sidegrade(XComGameState_PointOfInterest POIState)
{
	return (default.SIDEGRADE_SCANSITES
		 && (`XCOMHQ.IsTechResearched('MagnetizedWeapons')
		 || `XCOMHQ.IsTechResearched('PlatedArmor'))
	);
}

static function bool HasAllTier3_Sidegrade(XComGameState_PointOfInterest POIState)
{
	return (default.SIDEGRADE_SCANSITES
		 && `XCOMHQ.IsTechResearched('PlasmaRifle')
		 && `XCOMHQ.IsTechResearched('HeavyPlasma')
		 && `XCOMHQ.IsTechResearched('PlasmaSniper')
		 && `XCOMHQ.IsTechResearched('AlloyCannon')
		 && `XCOMHQ.IsTechResearched('PoweredArmor')
	);
}