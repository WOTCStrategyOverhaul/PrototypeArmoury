class PAHelpers extends Object abstract;

static function bool IsDLCLoaded (coerce string DLCName)
{
    local XComOnlineEventMgr EventManager;
    local int                Index;
	
	`PA_Trace("Checking if loaded: " $ DLCName);

	if (DLCName == "")
		return true;

    EventManager = `ONLINEEVENTMGR;
	
    for (Index = 0; Index < EventManager.GetNumDLC(); Index++)    
    {
        if(EventManager.GetDLCNames(Index) == name(DLCName))    
        {
            return true;
        }
    }

    return false;
}

///////////////////
/// Log helpers ///
///////////////////
// Call these only via macros

static function LogWarn (string message, bool bStack, optional bool bLog = true, optional bool bRedScreen = true)
{
	local array<string> StackLines;
	local string sStack;

	if (bStack)
	{
		sStack = GetScriptTrace();

		// Remove first ("Script call stack") and last line (this function)
		StackLines = SplitString(sStack, "\n", true);
		StackLines.Remove(0, 1);
		StackLines.Remove(StackLines.Length - 1, 1);

		// Convert back to string
		JoinArray(StackLines, sStack, "\n", true);

		// Add a line break before the stack
		sStack = "\n" $ sStack;
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
