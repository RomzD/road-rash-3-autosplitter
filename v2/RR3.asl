

state("Fusion")
{
byte startRun : 0x2A52D4,0x04DB; 	//byte changes to more or equal than 0xF0 when race stars
byte endRace : 0x2A52D4, 0x0521;	//end of the race.
byte time :  0x2A52D4,  0x099c;		//1st byte of time game counts by itself
byte sec :  0x2A52D4,  0x099D; 		//2nd byte of time game counts by itself
byte isFinalTime : 0x2A52D4, 0x0997;//2nd byte of whole track time(even counts after finish)

byte mainTimer1 : 0x2A52D4, 0x0997;	// 2nd byte of 2nd whole track timer. starts a bit later than 0x0991 &0x0990
byte mainTimer : 0x2A52D4, 0x0996;	// 1st byte of 2nd whole track timer.
byte mainTimer3 : 0x2A52D4, 0x0990;	// 1st byte of whole track timer
byte mainTimer4 : 0x2A52D4, 0x0991;	// 1st byte of whole track timer 

byte laterEndRace :  0x2A52D4,0x0989 // end of race. Maybe ticks later than other var
//byte sec :  0x2A52D4,  0x099D; 	// 2nd byte of proper game time game counts by itself after finish
//byte time :  0x2A52D4,  0x099c;	// 2nd byte of proper game time game counts by itself after finish
}

startup{
refreshRate=480;
}

start{

  if (current.startRun > 0x0f) return true;
	
}

isLoading{
	if	( 
		(current.mainTimer3 == 0  && current.mainTimer4 ==0)  ||	
	    (current.mainTimer == 0  && current.mainTimer1 ==0  ) ||
		 current.laterEndRace == 1 							  || 									
		 current.startRun < 0xf0									
		)
		
	{
	//print ("Current maintimer is " + current.mainTimer.ToString("X") +"curr endrace" +current.endRace + "current startrun"+ current.startRun);
	return true;
	}
	else{ 
	return false;}
}

split{ 
		if (current.laterEndRace==1 && old.laterEndRace ==0){
		TimeSpan myTime = (TimeSpan) timer.GameTimePauseTime;
		string strMilliseconds = (myTime.Milliseconds.ToString());
		int intMilliseconds= Int32.Parse(strMilliseconds[0]+"4"+"5");
		
		print("Millseconds are -" + strMilliseconds);
		TimeSpan newGameTime = new TimeSpan(0,myTime.Hours, myTime.Minutes,myTime.Seconds, intMilliseconds);
		timer.GameTimePauseTime = newGameTime; //"00:00:09.5000000";
		
		return true;
		}
}

gameTime{

}

update{
//TimeSpan myTime = (TimeSpan) timer.GameTimePauseTime;
//print("Timer is " +  Int32.Parse(((myTime.Milliseconds.ToString())[0]) +"0" +"0"));
}
