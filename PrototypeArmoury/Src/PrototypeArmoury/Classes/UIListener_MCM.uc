class UIListener_MCM extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local PrototypeArmoury_MCMScreen MCMScreen;

	if (MCM_API(Screen) == none) return;

	MCMScreen = new class'PrototypeArmoury_MCMScreen';
	MCMScreen.OnInit(Screen);
}
