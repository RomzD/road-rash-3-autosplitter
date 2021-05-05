

state("Fusion")
{
byte startRun : 0x2A52D4,0x04DB; 	//byte changes to more or equal than 0xF0 when race stars
byte time :  0x2A52D4,  0x099c;		//1st byte of time game counts by itself
byte sec :  0x2A52D4,  0x099D; 		//2nd byte of time game counts by itself
byte isFinalTime : 0x2A52D4, 0x0997;//2nd byte of whole track time(even counts after finish)

byte mainTimer1 : 0x2A52D4, 0x0997;	// 2nd byte of 2nd whole track timer. starts a bit later than 0x0991 &0x0990
byte mainTimer : 0x2A52D4, 0x0996;	// 1st byte of 2nd whole track timer.
byte mainTimer3 : 0x2A52D4, 0x0990;	// 1st byte of whole track timer
byte mainTimer4 : 0x2A52D4, 0x0991;	// 1st byte of whole track timer 

byte endRace :  0x2A52D4,0x0521;    // end of race. Maybe ticks later than other var
byte ingameSec :  0x2A52D4,0x09a4;
byte ingameMin :  0x2A52D4,0x09a5;

byte timeSubsctaction : 0x2A52D4, 0x096f;

//byte endRace : 0x2A52D4, 0x0521;	//end of the race.
//byte endRace :  0x2A52D4,0x0989   //end of the race too, but maybe ticks a little bit later

}

startup{
	refreshRate=60;
	vars.wholeTime = 0;
}

start{
  if (current.startRun > 0x0f) return true;	
  vars.wholeTime = 0;
}

isLoading{
			if	( 
				(current.mainTimer3 == 0  && current.mainTimer4 ==0)  ||																
				 current.endRace == 1 							 	  || 									
				 current.startRun < 0xf0									
				)				
			{			
			return true;
			}
			else{ 
			return false;}
}

split{ 
		if  (current.endRace==1 && 				  		 //prevent overheading comparisons
				(current.sec != old.sec)&& 			     //prevent snowball spliting
				(current.isFinalTime != current.sec)  && //skip from split initial final time initialization in secs & time variables
				(current.sec != 0 && current.time !=0) //don't trigger splits if random byte will pass to memory cell. For safety
				//&&( )                     //prevent split trigger with low values. Sometimes it happens 
			)  		
				{

		if ((Convert.ToInt16(current.time.ToString("X") + current.sec.ToString("X"),16))> 5000){
					
	    print("Line 58, current time is" + current.time.ToString("X") + " current sec is " + current.sec.ToString("X") + ("current time in hex(raw)") + current.time + " timeSubsctaction is " + current.timeSubsctaction + " time is" + current.time + " sec is " + current.sec);
		TimeSpan myTime = (TimeSpan) timer.GameTimePauseTime;
		print("Line 60, myTime is" + myTime.ToString());
		string strMilliseconds = (myTime.Milliseconds.ToString());
		print("Line 62, strMilliseconds is "+strMilliseconds);
		int originalMS = (strMilliseconds.Length >1) ? Int32.Parse(strMilliseconds[strMilliseconds.Length-2].ToString() + strMilliseconds[strMilliseconds.Length-1].ToString()) : Int32.Parse(strMilliseconds);
		print("Line 64, originalMS is " + originalMS);
		int intMilliseconds= Int32.Parse(strMilliseconds[0]+"0"+"0");   //setting offset with "#"+"#" (hundreds, thousands), since split triggers a little bit earlier than game stops count time
		print("Line 66, intMilliseconds is " + intMilliseconds);
				
		int intTime = (Convert.ToInt16(current.time.ToString("X") + current.sec.ToString("X"),16));
		print("Line 69, intTime is " + intTime);
		string trackTime = (((double)intTime)/60).ToString();
		print("Line 71, trackTime is " + trackTime);
		trackTime = trackTime.Substring(0,trackTime.IndexOf(",")+2);
		print("Line 73, trackTime after substring is " + trackTime);
		print("Before assign vars.wholeTime" + vars.wholeTime +" (double)trackTime " + Double.Parse(trackTime));
		print("Line 75");
		vars.wholeTime =   vars.wholeTime + Double.Parse(trackTime);
	    print("Line  77, wholeTime is " + vars.wholeTime);
		string wholeTimeStr = vars.wholeTime.ToString();
		print("Line 79, wholeTimeStr is " + wholeTimeStr);
		int mins = ((int)vars.wholeTime)/60;
		print("Line 81, mins is " + mins);
		int runHours = mins/60;
		print("Line 83, runHours is " + runHours);
		int secs = ((int)vars.wholeTime) -(60*mins);
		print("Line 85, secs is " + secs);
		int ms = wholeTimeStr.IndexOf(",")<1 ? 0: Int32.Parse(wholeTimeStr.Substring(wholeTimeStr.IndexOf(",")+1,1));
		
		
		print("Line 89, ms is " + ms);
		print ("Tracktime is " +trackTime + " track time is" + intTime +"vars.wholeTime "+ vars.wholeTime + " curr mins "+ mins +" curr secs "+ secs +" curr ms " +ms +" hours "+ runHours);
		TimeSpan newGameTime = new TimeSpan(0,TimeSpan.FromHours(runHours).Hours,TimeSpan.FromMinutes(mins).Minutes, TimeSpan.FromSeconds(secs).Seconds, TimeSpan.FromMilliseconds(ms*100).Milliseconds);
		print("Timer hours" + TimeSpan.FromHours(runHours).ToString() +"Timer minutes " +TimeSpan.FromMinutes(mins) +" Timer seconds " + TimeSpan.FromSeconds(secs) +" Timer ms " +TimeSpan.FromMilliseconds(ms*100).Milliseconds);
		//TimeSpan newGameTime = new TimeSpan(0,TimeSpan.FromHours(runHours), TimeSpan.FromMinutes(mins),TimeSpan.FromSeconds(secs), TimeSpan.FromMilliseconds(ms*100) );
		timer.GameTimePauseTime = newGameTime; 		
		return true;
		}// end of inner 
		else {
				print ("mainTimer is " + current.mainTimer + " mainTimer1 is " + current.mainTimer1 + " mainTimer3 is"+ current.mainTimer3 + " mainTimer4 is " + current.mainTimer4);
				int ingSec = current.ingameSec.ToString("X");
				int ingMin = current.ingameMin.ToString("X");
				print (" AAAAAAAA LINE 101 SMALL INGAME TIME ingame min & sec are" + ingSec +"-" + ingMin);
				int finalTimeWithoutTenth  =  ingSec + ingMin *60;
				print ("Line 103 finalTimeWithoutTenth is " + finalTimeWithoutTenth);
				string finalTenth = ((Convert.ToInt16(current.time.ToString("X") + current.sec.ToString("X"),16))/60).ToString();
				finalTenth = "0." +finalTenth.Substring(finalTenth.IndexOf(",")+ 1 , 1  );
				double finalTime = (double) finalTimeWithoutTenth  + Double.Parse(finalTenth);
				print ("double finaltime is "+ finalTime);
				string trackTime = finalTime.ToString();
				vars.wholeTime =   vars.wholeTime + Double.Parse(trackTime);
				string wholeTimeStr = vars.wholeTime.ToString();
				print("Line 111, wholeTimeStr is " + wholeTimeStr);
				int mins = ((int)vars.wholeTime)/60;
				print("Line 114, mins is " + mins);
				int runHours = mins/60;
				print("Line 115, runHours is " + runHours);
				int secs = ((int)vars.wholeTime) -(60*mins);
				print("Line 117, secs is " + secs);
				int ms = wholeTimeStr.IndexOf(",")<1 ? 0: Int32.Parse(wholeTimeStr.Substring(wholeTimeStr.IndexOf(",")+1,1));
				
				TimeSpan newGameTime = new TimeSpan(0,TimeSpan.FromHours(runHours).Hours,TimeSpan.FromMinutes(mins).Minutes, TimeSpan.FromSeconds(secs).Seconds, TimeSpan.FromMilliseconds(ms*100).Milliseconds);
				print("Timer hours" + TimeSpan.FromHours(runHours).ToString() +"Timer minutes " +TimeSpan.FromMinutes(mins) +" Timer seconds " + TimeSpan.FromSeconds(secs) +" Timer ms " +TimeSpan.FromMilliseconds(ms*100).Milliseconds);
				//TimeSpan newGameTime = new TimeSpan(0,TimeSpan.FromHours(runHours), TimeSpan.FromMinutes(mins),TimeSpan.FromSeconds(secs), TimeSpan.FromMilliseconds(ms*100) );
				timer.GameTimePauseTime = newGameTime; 
					
				return true;
			}
		}// end of main if
		
}


gameTime{
/*
int intTime = (Convert.ToInt16(current.time.ToString("X") + current.sec.ToString("X"),16));
int mins = intTime/3600;
int secs = (intTime/60) -(60*mins);
string milSecs =   ((((float)intTime)/60).ToString());
int tenth=(int)(Char.GetNumericValue(milSecs[milSecs.IndexOf(',',0)+1]));

vars.currSegmentMin =mins;
vars.currSegmentSec =secs;
vars.currSegmentTenth = tenth;

mins += vars.prevSegmentMin;
secs += vars.prevSegmentSec;
tenth += vars.prevSegmentTenth;




TimeSpan IGT = new TimeSpan(0,0,mins,secs, (tenth*100) );//since timespan ticks and does not guarantees proper return value, lets move it back in tame from needed value to 20 ms back
//print("gameTime IGT " + milSecs +"index after dot " +milSecs[milSecs.IndexOf(',',0)+1] +"calculated value" + ((int)(Char.GetNumericValue(milSecs[milSecs.IndexOf(',',0)+1])))*100);
return IGT;*/
}

update{
}