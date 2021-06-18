class PA_DataStructures extends Object abstract;

const DEFAULT_EVENT_PRIORITY = 91;

struct ItemAvaliableImageReplacement
{
	var name TargetItem;
	
	// Directly set the image (preferred)
	var string strImage;
	
	// Pull image from template
	var name ImageSourceItem;
};

struct TradingPostValueModifier
{
	var name ItemName;
	var int NewValue;
	var name DLC;
};

struct ItemCostOverride
{
	var name ItemName;
	var array<int> Difficulties;
	var StrategyCost NewCost;
	var name DLC;
	var bool bApplyCostScalars;
};

struct AutoItemConversion
{
	var name ItemName;
	var int Supplies;
	var int Alloys;
	var int Elerium;
	var name DLC;
};

struct ItemFromDLC
{
	var name ItemName;
	var name DLC;
};
