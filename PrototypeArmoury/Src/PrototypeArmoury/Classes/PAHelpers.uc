class PAHelpers extends Object abstract;

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
