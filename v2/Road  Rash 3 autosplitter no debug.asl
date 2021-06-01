

state("Fusion")
{
byte startRun  	 : 0x2A52D4, 0x04DB; 	//byte changes to more or equal than 0xF0 when race stars
byte time 		 : 0x2A52D4, 0x099c;	//1st byte of time game counts by itself
byte sec 		 : 0x2A52D4, 0x099D; 	//2nd byte of time game counts by itself
byte isFinalTime : 0x2A52D4, 0x0997;	//2nd byte of whole track time(even counts after finish)

byte mainTimer1 : 0x2A52D4, 0x0997;		// 2nd byte of 2nd whole track timer. starts a bit later than 0x0991 &0x0990
byte mainTimer  : 0x2A52D4, 0x0996;		// 1st byte of 2nd whole track timer.
byte mainTimer3 : 0x2A52D4, 0x0990;		// 1st byte of whole track timer
byte mainTimer4 : 0x2A52D4, 0x0991;		// 1st byte of whole track timer 

byte endRace   :  0x2A52D4,0x0521;   	// end of race. Maybe ticks later than other var
byte ingameSec :  0x2A52D4,0x09a5;
byte ingameMin :  0x2A52D4,0x09a4;

byte timeSubsctaction : 0x2A52D4, 0x096f;
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
		if  	
		(current.endRace==1					  && 				  		 
		(current.sec != old.sec)			  && 			     
		(current.isFinalTime != current.sec)  && 
		(current.sec != 0 && current.time !=0) 
		){

		if ((Convert.ToInt16(current.time.ToString("X") + current.sec.ToString("X"),16))> 5000){
					
	   
		TimeSpan myTime = (TimeSpan) timer.GameTimePauseTime;
		
		string strMilliseconds = (myTime.Milliseconds.ToString());		
		int originalMS = (strMilliseconds.Length >1) ? Int32.Parse(strMilliseconds[strMilliseconds.Length-2].ToString() + strMilliseconds[strMilliseconds.Length-1].ToString()) : Int32.Parse(strMilliseconds);		
		int intMilliseconds= Int32.Parse(strMilliseconds[0]+"0"+"0");   //setting offset with "#"+"#" (hundreds, thousands), since split triggers a little bit earlier than game stops count time
		
				
		int intTime = (Convert.ToInt16(current.time.ToString("X") + current.sec.ToString("X"),16));		
		string trackTime = (((double)intTime)/60).ToString();		
		trackTime = trackTime.Substring(0,trackTime.IndexOf(",")+2);

		
		vars.wholeTime =   vars.wholeTime + Double.Parse(trackTime);	    
		string wholeTimeStr = vars.wholeTime.ToString();	

		
		int mins = ((int)vars.wholeTime)/60;		
		int runHours = mins/60;		
		int secs = ((int)vars.wholeTime) -(60*mins);		
		int ms = wholeTimeStr.IndexOf(",")<1 ? 0: Int32.Parse(wholeTimeStr.Substring(wholeTimeStr.IndexOf(",")+1,1));

		TimeSpan newGameTime = new TimeSpan(0,TimeSpan.FromHours(runHours).Hours,TimeSpan.FromMinutes(mins).Minutes, TimeSpan.FromSeconds(secs).Seconds, TimeSpan.FromMilliseconds(ms*100).Milliseconds);		
		timer.GameTimePauseTime = newGameTime; 	
		
		return true;
		}// end of inner if
		else {
				int ingSec = Convert.ToInt32(current.ingameSec.ToString("X"));
				int ingMin = Convert.ToInt32(current.ingameMin.ToString("X"));
				
				int finalTimeWithoutTenth  =  ingSec + ingMin *60;				
				int shortStr = Convert.ToInt16( current.time.ToString("X") + current.sec.ToString("X"),16);
 				string finalTenth = ((Double.Parse(    shortStr.ToString()  ))/60).ToString();
				finalTenth = finalTenth.IndexOf(",") == -1 ? "0,0": "0,"+ finalTenth.Substring(finalTenth.IndexOf(",")+ 1 , 1 ).ToString() ;
				
				double finalTime =  (double) finalTimeWithoutTenth  + Double.Parse(finalTenth);
				
				string trackTime = finalTime.ToString();
				vars.wholeTime =   vars.wholeTime + Double.Parse(trackTime);
				string wholeTimeStr = vars.wholeTime.ToString();
				
				int mins = ((int)vars.wholeTime)/60;				
				int runHours = mins/60;				
				int secs = ((int)vars.wholeTime) -(60*mins);				
				int ms = wholeTimeStr.IndexOf(",")<1 ? 0: Int32.Parse(wholeTimeStr.Substring(wholeTimeStr.IndexOf(",")+1,1));
				
				TimeSpan newGameTime = new TimeSpan(0,TimeSpan.FromHours(runHours).Hours,TimeSpan.FromMinutes(mins).Minutes, TimeSpan.FromSeconds(secs).Seconds, TimeSpan.FromMilliseconds(ms*100).Milliseconds);								
				timer.GameTimePauseTime = newGameTime; 
					
				return true;
			}
		}// end of main if
		
}


gameTime{
}

update{	
}