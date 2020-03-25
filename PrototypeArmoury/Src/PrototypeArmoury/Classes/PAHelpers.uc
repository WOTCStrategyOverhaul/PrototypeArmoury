class PAHelpers extends Object abstract;

///////////////////
/// Log helpers ///
///////////////////
// Call these only via macros

static function LogWarn (string message, bool bStack, optional bool bLog = true, optional bool bRedScreen = true)
{
	local string sStack;

	if (bStack)
	{
		sStack = GetScriptTrace();
	}

	if (bLog)
	{
		`log(message $ sStack,, 'PrototypeArmoury_Warning');
	}

	if (bRedScreen)
	{
		`RedScreen("PrototypeArmoury:" @ message $ sStack);
	}
}
