//Resident Evil 4 Remake Autosplitter V1.0.5 (02/10/2023)
//Supports IGT and Game Splits for both main game & Separate Ways
//Script & Pointers by TheDementedSalad
//Special Thanks to:
//Yuushi & AvuKamu for going through the game and collecting data for splits

state("re4","Release")
{
   long GameElapsedTime		: 0xD234048, 0x18, 0x38;		//share.GameClock
   long DemoSpendingTime	: 0xD234048, 0x18, 0x40;		//""
   long PauseSpendingTime	: 0xD234048, 0x18, 0x50;		//""
   long ChapterTimeStart	: 0xD20FF80, 0x20, 0x10, 0x18;  //chainsaw.GameStatsManager > OngoingStats
   
   int Cutscene				: 0xD21B2C8, 0x17C;				//10157 sacrifice cutscene, 10003 Leon in car, -1 no cutscene
   int Chapter				: 0xD2368B0, 0x30;				//chainsaw.CampaignManager > CurrentChapter
   int Map					: 0xD2368B0, 0x38, 0x14;		//"" 					   > Stage
   int ItemID				: 0xD22B258, 0xE0, 0xE8;		//HighwayGuiManager > _CsItemWindowGuiControlBehavior > _GetItemID
}

state("re4","7/4/23")
{
   long GameElapsedTime		: 0xD22D7D0, 0x18, 0x38;		
   long DemoSpendingTime	: 0xD22D7D0, 0x18, 0x40;
   long PauseSpendingTime	: 0xD22D7D0, 0x18, 0x50;
   long ChapterTimeStart	: 0xD217780, 0x20, 0x10, 0x18;
	
   int Cutscene				: 0xD222610, 0x17C;	
   int Chapter				: 0xD22B018, 0x30;
   int Map					: 0xD22B018, 0x38, 0x14;
   int ItemID				: 0xD22B240, 0xE0, 0xE8;		
   
   byte DARank				: 0xD22B1A0, 0x10;
   float ActionPoint 		: 0xD22B1A0, 0x14;
   float ItemPoint			: 0xD22B1A0, 0x18;
}

state("re4","24/4/23")
{
   long GameElapsedTime		: 0xD257048, 0x18, 0x38;
   long DemoSpendingTime	: 0xD257048, 0x18, 0x40;
   long PauseSpendingTime	: 0xD257048, 0x18, 0x50;
   long ChapterTimeStart	: 0xD2470C8, 0x20, 0x10, 0x18;
	
   int Cutscene				: 0xD257428, 0x17C;	
   int Chapter				: 0xD259508, 0x30;
   int Map					: 0xD259508, 0x38, 0x14;
   int ItemID				: 0xD260470, 0xE0, 0xF0;
   
   byte DARank				: 0xD2603D0, 0x10;
   float ActionPoint 		: 0xD2603D0, 0x14;
   float ItemPoint			: 0xD2603D0, 0x18;
}

state("re4","21/9/23")
{
   long GameElapsedTime		: 0xDC078D8, 0x18, 0x38;
   long DemoSpendingTime	: 0xDC078D8, 0x18, 0x40;
   long PauseSpendingTime	: 0xDC078D8, 0x18, 0x50;
   long ChapterTimeStart	: 0xDBBDA10, 0x20, 0x10, 0x18;
	
   int Cutscene				: 0xDBC2C80, 0x18C;	
   int gameState			: 0xDBC2C80, 0x194;	
   int Chapter				: 0xDBC2848, 0x30;
   int Map					: 0xDBC2848, 0x38, 0x14;
   int ItemID				: 0xDBC2AA0, 0xE0, 0xF0;
   
   byte DARank              : 0xDBC2A00, 0x10;
   float ActionPoint        : 0xDBC2A00, 0x14;
   float ItemPoint          : 0xDBC2A00, 0x18;
}

state("re4","2/10/23")
{
   long GameElapsedTime		: 0xDBBB360, 0x20, 0x18;
   long DemoSpendingTime	: 0xDBBB360, 0x20, 0x20;
   long PauseSpendingTime	: 0xDBBB360, 0x20, 0x30;
   long ChapterTimeStart	: 0xDBB39D0, 0x20, 0x10, 0x18;
	
   int Cutscene				: 0xDBB8C40, 0x18C;	
   int gameState			: 0xDBB8C40, 0x194;	
   int Chapter				: 0xDBB8808, 0x30;
   int Map					: 0xDBB8808, 0x38, 0x14;
   int ItemID				: 0xDBB8A60, 0xE0, 0xF0;
   
   byte DARank              : 0xDBB89C0, 0x10;
   float ActionPoint        : 0xDBB89C0, 0x14;
   float ItemPoint          : 0xDBB89C0, 0x18;
}

init
{
	vars.StartTime = 0;
	vars.completedSplits = new List<int>();
	vars.mendezKey = new List <int>();
	
	switch (modules.First().ModuleMemorySize)
	{
		case (548831232):
		case (538660864):
			version = "7/4/23";
			break;
		case (553566208):
			version = "24/4/23";
			break;
		case (541417472):
			version = "21/9/23";
			break;
		case (561971200):
		case (553279488):
			version = "2/10/23";
			break;
		default:
			version = "Release";
			break;
	}
}

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

update
{
	//print(modules.First().ModuleMemorySize.ToString());
	
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedSplits.Clear();
		vars.mendezKey.Clear();
	}
	
	if(current.Cutscene == 10003 && old.Cutscene == -1 && current.Map == 40500 || current.Cutscene == 50000 && old.Cutscene == -1 && current.Map == 50502){
		vars.StartTime = current.ChapterTimeStart;
		return true;
	}
	
	if(current.ItemID == 118920000 && !vars.mendezKey.Contains(118920000)){
		vars.mendezKey.Add(current.ItemID);
	}
}

gameTime
{
	return TimeSpan.FromSeconds((current.GameElapsedTime - current.DemoSpendingTime - current.PauseSpendingTime - vars.StartTime) / 1000000.0);
}

start
{
	return current.Cutscene == 10003 && old.Cutscene == -1 && current.Map == 40500 || current.Cutscene == -1 && old.Cutscene == 50000 && current.Map == 50502;
}

split
{
	if(settings["" + current.Chapter] && !vars.completedSplits.Contains(current.Chapter)){
		vars.completedSplits.Add(current.Chapter);
		return true;
	}
	
	if(settings["" + current.Cutscene] && !vars.completedSplits.Contains(current.Cutscene)){
		vars.completedSplits.Add(current.Cutscene);
		return true;
	}
	
	if(settings["" + current.Map] && !vars.completedSplits.Contains(current.Map)){
		vars.completedSplits.Add(current.Map);
		return true;
	}
	
	if(settings["" + current.ItemID] && !vars.completedSplits.Contains(current.ItemID)){
		vars.completedSplits.Add(current.ItemID);
		return true;
	}
	
	if(settings["Merch"] && current.Chapter == 22100 && current.Map == 46210 && !vars.completedSplits.Contains(current.Map)){
		vars.completedSplits.Add(current.Map);
		return true;
	}
	
	if((settings["Merch"] && current.Map == 46210 || settings["Church"] && current.Map == 45401) && current.Chapter == 22100 && !vars.completedSplits.Contains(current.Map)){
		vars.completedSplits.Add(current.Map);
		return true;
	}
	
	if((settings["Town"] && current.Map == 40213 || settings["Barn"] && current.Map == 43300) && current.Chapter == 22200 && !vars.completedSplits.Contains(current.Map)){
		vars.completedSplits.Add(current.Map);
		return true;
	}
	
	if(settings["MenStart"] && current.gameState == 10 && vars.mendezKey.Contains(118920000) && !vars.completedSplits.Contains(118920000)){
		vars.completedSplits.Add(118920000);
		return true;
	}
	
	if(settings["Wreck"] && current.Map == 62200 && current.Chapter == 34100 && !vars.completedSplits.Contains(current.Map)){
		vars.completedSplits.Add(current.Map);
		return true;
	}
}


isLoading
{
	return true;
}

reset
{
	return current.Cutscene == 10157 && old.Cutscene == -1 || current.Cutscene == 50000 && old.Cutscene == -1;
	vars.StartTime = 0;
}

exit
{
    //pauses timer if the game crashes
	timer.IsGameTimePaused = true;
}
