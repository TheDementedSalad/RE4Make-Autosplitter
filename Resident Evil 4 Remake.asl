//Resident Evil 4 Remake Autosplitter V1.0 (26/03/2023)
//Supports IGT and Chapter Splits

state("re4")
{
   long GameElapsedTime		: 0xD234048, 0x18, 0x38;
   long DemoSpendingTime	: 0xD234048, 0x18, 0x40;
   long PauseSpendingTime	: 0xD234048, 0x18, 0x50;
   long ChapterTimeStart	: 0xD20FF80, 0x20, 0x10, 0x18;
	
   int Map					:	0xD2382B0, 0x88, 0x20;			//5050000 next to the beginning car, 5050100 after bushes
   int Chapter				:	0xD21B2C8, 0x154;
   int CutsceneID			: 	0xD21B2C8, 0x17C;			
   int MovieID				:	0xD21B2C8, 0x180;				//10600 when intro movie is playing, -1 otherwise
}

startup
{
	vars.StartTime = 0;
	vars.completedCutscene = new List<int>();
	vars.completedChapter = new List<int>();
	
	settings.Add("Chap", false, "Timing Method");
	settings.CurrentDefaultParent = "Chap";
	settings.Add("21200", true, "Chapter 1");
	settings.Add("21300", true, "Chapter 2");
	settings.Add("22100", true, "Chapter 3");
	settings.Add("22200", true, "Chapter 4");
	settings.Add("22300", true, "Chapter 5");
	settings.Add("23100", true, "Chapter 6");
	settings.Add("23200", true, "Chapter 7");
	settings.Add("23300", true, "Chapter 8");
	settings.Add("24100", true, "Chapter 9");
	settings.Add("24200", true, "Chapter 10");
	settings.Add("24300", true, "Chapter 11");
	settings.Add("25100", true, "Chapter 12");
	settings.Add("25200", true, "Chapter 13");
	settings.Add("25300", true, "Chapter 14");
	settings.Add("25400", true, "Chapter 15");
	settings.CurrentDefaultParent = null;
	
	settings.Add("10075", true, "Chapter 16 (Always Active)");
}

update
{
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedCutscene.Clear();
		vars.completedChapter.Clear();
	}
	
	if(current.CutsceneID == 10003 && old.CutsceneID == -1){
		vars.StartTime = current.ChapterTimeStart;
		return true;
	}
}

gameTime
{
	return TimeSpan.FromSeconds((current.GameElapsedTime - current.DemoSpendingTime - current.PauseSpendingTime - vars.StartTime) / 1000000.0);
}

start
{
	return current.CutsceneID == -1 && old.CutsceneID == 10003;
}

split
{
	if(settings["" + current.CutsceneID] && !vars.completedCutscene.Contains(current.CutsceneID)){
		vars.completedCutscene.Add(current.CutsceneID);
		return true;
	}
	
	if(settings["" + current.Chapter] && !vars.completedChapter.Contains(current.Chapter)){
		vars.completedChapter.Add(current.Chapter);
		return true;
	}
}


isLoading
{
	return true;
}

reset
{
	return current.CutsceneID == 10003 && old.CutsceneID == -1;
}

exit
{
    //pauses timer if the game crashes
	timer.IsGameTimePaused = true;
}