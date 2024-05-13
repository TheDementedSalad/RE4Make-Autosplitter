//Resident Evil 4 Remake Autosplitter V2.0.0 (13/05/2024)
//Supports IGT and Game Splits for both main game & Separate Ways
//Script & Pointers by TheDementedSalad
//Special Thanks to:
//Yuushi & AvuKamu for going through the game and collecting data for splits

state("re4"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.Settings.CreateFromXml("Components/RE4make.Settings.xml");
	
	// Asks user to change to game time if LiveSplit is currently set to Real Time.
		if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This game uses In Game Time as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Resident Evil 4 (2023)",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );

        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
}

init
{
	/*
	switch (modules.First().ModuleMemorySize)
	{
		case (540995584):
		case (548831232):
		case (538660864):
		case (553566208):
			version = "Pre SW";
			break;
		default:
			version = "Post SW";
			break;
	}
	*/
	
	IntPtr GameClock = vars.Helper.ScanRel(3, "48 8b 15 ?? ?? ?? ?? e8 ?? ?? ?? ?? 48 89 43 ?? 48 c7 43");
	IntPtr GameStatsManager = vars.Helper.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 8b d9 48 8b 42");
	IntPtr CampaignManager = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 4c 8b 80 ?? ?? ?? ?? 49 8b 40");
	IntPtr SoundGame10Manager = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 4c 8b c2 48 8b 90");
	IntPtr MenuState = vars.Helper.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 8b cb 4c 8b 42 ?? 48 83 c4");
	IntPtr Items = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 8b 50 ?? e9");
	IntPtr EventTimelineMediator = vars.Helper.ScanRel(3, "48 8b 1d ?? ?? ?? ?? 48 8b f2 48 8b f9 e8");
	IntPtr GameRankSystem = vars.Helper.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 44 8b 40 ?? 44 89 82");
	
	vars.Helper["GameElapsedTime"] = vars.Helper.Make<long>(GameClock, 0x20, 0x18);
	vars.Helper["DemoSpendingTime"] = vars.Helper.Make<long>(GameClock, 0x20, 0x20);
	vars.Helper["InvSpendingTime"] = vars.Helper.Make<long>(GameClock, 0x20, 0x28);
	vars.Helper["PauseSpendingTime"] = vars.Helper.Make<long>(GameClock, 0x20, 0x30);
	vars.Helper["ChapterTimeStart"] = vars.Helper.Make<long>(GameStatsManager, 0x20, 0x10, 0x18);
	vars.Helper["Difficulty"] = vars.Helper.Make<int>(CampaignManager, 0x28);
	vars.Helper["Chapter"] = vars.Helper.Make<int>(CampaignManager, 0x30);
	vars.Helper["EnvLoaderPhase"] = vars.Helper.Make<byte>(CampaignManager, 0xF8);
	vars.Helper["MapID"] = vars.Helper.Make<int>(CampaignManager, 0x38, 0x14);
	vars.Helper["Menu"] = vars.Helper.Make<byte>(MenuState, 0x30, 0x40);
	vars.Helper["ItemID"] = vars.Helper.Make<int>(Items, 0xE0, 0xF0);
	vars.Helper["Cutscene"] = vars.Helper.Make<int>(EventTimelineMediator, 0x20, 0x10, 0x20);
	
	vars.StartTime = 0f;
	vars.PauseStart = 0f;
	vars.PauseHold = 0f;
	vars.PauseTime = 0f;
	vars.TotalTimeInSeconds = 0f;
	vars.completedSplits = new HashSet<string>();
	
	vars.Clock = GameClock;
	vars.AP = GameRankSystem;
	
	/*
	if (version == "Pre SW"){
		vars.Helper["Cutscene"] = vars.Helper.Make<int>(SoundGame10Manager, 0x17C);
		vars.Helper["gameState"] = vars.Helper.Make<int>(SoundGame10Manager, 0x184);
	}
	
	else{
		vars.Helper["Cutscene"] = vars.Helper.Make<int>(SoundGame10Manager, 0x18C);
		vars.Helper["gameState"] = vars.Helper.Make<int>(SoundGame10Manager, 0x194);
	}
	*/
}

onStart
{
	vars.TotalTimeInSeconds = 0f;
	vars.PauseStart = 0f;
	vars.PauseHold = 0f;
	vars.PauseTime = 0f;
	vars.completedSplits.Clear();
	vars.Helper.Texts.RemoveAll();
	
	vars.Helper.Texts["Total Time"].Left = "Time Spent Paused:";
	vars.Helper.Texts["Total Time"].Right = "00:00";
}

start
{
	return current.Cutscene == 0 && old.Cutscene == 10003 && current.MapID == 40500 || current.Cutscene == 0 && old.Cutscene == 50000 && current.MapID == 50502;
}


update
{
	//print(modules.First().ModuleMemorySize.ToString());
	vars.Helper.Update();
	vars.Helper.MapPointers();

	/*
	if(current.Cutscene == 10003 && old.Cutscene == -1 && current.Map == 40500 || current.Cutscene == 50000 && old.Cutscene == -1 && current.Map == 50502){
		vars.StartTime = current.ChapterTimeStart;
		return true;
	}
	*/
	
	if(current.ItemID == 118920000 && vars.mendezKey == false){
		vars.mendezKey = true;
	}
	
	if((current.Chapter == 21100 || current.Chapter == 30100) && old.Chapter == -1){
		vars.PauseHold = 0f;
		vars.PauseTime = 0f;
		vars.PauseStart = 0f;
	}
	
	if(current.Menu == 7 && old.Menu != 7){
		vars.PauseStart = current.PauseSpendingTime;
	}
	
	if(current.Menu != 7 && old.Menu == 7){
		vars.PauseHold = vars.PauseHold + current.PauseSpendingTime - vars.PauseStart;
	}
	
	if(current.Menu == 7 && timer.CurrentPhase == TimerPhase.Running){
        vars.PauseTime = current.PauseSpendingTime - vars.PauseStart;

        vars.TotalTimeInSeconds = vars.PauseHold + vars.PauseTime;
        vars.Helper.Texts["Total Time"].Right = TimeSpan.FromSeconds((vars.TotalTimeInSeconds) / 1000000.0).ToString(@"mm\:ss");
		
    }
	
	if(current.Cutscene == 10003 && old.Cutscene == 0 && current.MapID == 40500 || current.Cutscene == 0 && old.Cutscene == 50000 && current.MapID == 50502 || current.MapID == 43300 && current.EnvLoaderPhase == 1 && old.EnvLoaderPhase == 0){
		game.WriteValue<long>(game.ReadPointer(game.ReadPointer((IntPtr)vars.Clock) + 0x20) + 0x18, 0);
		game.WriteValue<long>(game.ReadPointer(game.ReadPointer((IntPtr)vars.Clock) + 0x20) + 0x20, 0);
		game.WriteValue<long>(game.ReadPointer(game.ReadPointer((IntPtr)vars.Clock) + 0x20) + 0x28, 0);
		game.WriteValue<long>(game.ReadPointer(game.ReadPointer((IntPtr)vars.Clock) + 0x20) + 0x30, 0);
	}
	
	if(settings["NoInt"]){
		if(current.MapID == 43300 && current.EnvLoaderPhase == 1 && old.EnvLoaderPhase == 0){
			switch ((byte)current.Difficulty){
				case 10:
					game.WriteValue<float>(game.ReadPointer((IntPtr)vars.AP) + 0x14, 3400);
					break;
				case 20:
					game.WriteValue<float>(game.ReadPointer((IntPtr)vars.AP) + 0x14, 4000);
					break;
				case 30:
					game.WriteValue<float>(game.ReadPointer((IntPtr)vars.AP) + 0x14, 3400);
					break;
				case 40:
					game.WriteValue<float>(game.ReadPointer((IntPtr)vars.AP) + 0x14, 3050);
					break;
			}
		}
	}
}

gameTime
{
	return TimeSpan.FromSeconds((current.GameElapsedTime - current.DemoSpendingTime - current.PauseSpendingTime) / 1000000.0);
}

split
{
	string setting = "";
	
	if(current.MapID != old.MapID){
		setting = "Map_" + current.MapID;
	}
	
	if(current.ItemID != old.ItemID){
		setting = "Item_" + current.ItemID;
	}
	
	if(current.Chapter != old.Chapter){
		setting = "Chapter_" + current.Chapter;
	}
	
	if(current.Cutscene != old.Cutscene && current.Cutscene != 0){
		setting = "Event_" + current.Cutscene;
	}
	
	if(current.Chapter == 22100 && current.MapID == 46210 && current.MapID != old.MapID){
		setting = "Split_Merch";
	}
	
	if(current.Chapter == 22100 && current.MapID == 45401 && current.MapID != old.MapID){
		setting = "Split_Church";
	}
	
	if(current.Chapter == 22200 && current.MapID == 40213 && current.MapID != old.MapID){
		setting = "Split_Town";
	}
	
	if(current.Chapter == 22200 && current.MapID == 43300 && current.MapID != old.MapID){
		setting = "Split_Barn";
	}
	
	if(current.Chapter == 34100 && current.MapID == 62200 && current.MapID != old.MapID){
		setting = "Split_Wreck";
	}
	
	// Debug. Comment out before release.
    if (!string.IsNullOrEmpty(setting))
    vars.Log(setting);

	if (settings.ContainsKey(setting) && settings[setting] && vars.completedSplits.Add(setting)){
		return true;
	}
}


isLoading
{
	return true;
}

reset
{
	return current.Cutscene == 10157 && old.Cutscene == 0 || current.Cutscene == 50000 && old.Cutscene == 0;
}

exit
{
    //pauses timer if the game crashes
	timer.IsGameTimePaused = true;
	vars.Helper.Texts.RemoveAll();
}
