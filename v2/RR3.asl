

state("Fusion")
{
byte startRun : 0x2A52D4,0x04DB; 	//byte changes to more or equal than 0xF0 when race stars
byte endRace : 0x2A52D4, 0x0521;	//end of the race. Pretty useless, since variables of proper game time still changing after the moment of finish
byte time :  0x2A52D4,  0x099c;		//1st byte of time game counts by itself
byte sec :  0x2A52D4,  0x099D; 		//2nd byte of time game counts by itself
byte isFinalTime : 0x2A52D4, 0x0997;// 2nd byte of whole track time(even counts after finish)

byte mainTimer1 : 0x2A52D4, 0x0990;
byte mainTimer : 0x2A52D4, 0x0991;
//byte sec :  0x2A52D4,  0x099D; //proper game time
//byte time :  0x2A52D4,  0x099c;//proper game time
//original address 0x0997;
}

startup{
refreshRate=120;
}

start{

  if (current.startRun > 0x0f) return true;
	
}/*
|| 
		current.endRace ==1 || 
		current.startRun < 0xf0) 
*/

isLoading{
	if	( 
		(current.mainTimer == 0  && current.mainTimer1 ==0)||
		current.endRace ==1 || 
		current.startRun < 0xf0
		) 
	{
	print ("Current maintimer is " + current.mainTimer.ToString("X") +"curr endrace" +current.endRace + "current startrun"+ current.startRun);
	return true;
	}
	else{ 
	return false;}
}

split{ 
		if (current.endRace==1 && old.endRace ==0){
		return true;
		}
}

gameTime{
}

update{

}