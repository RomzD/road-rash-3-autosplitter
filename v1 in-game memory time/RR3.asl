

state("Fusion")
{
byte startRun : 0x2A52D4,0x04DB; 	//byte changes to more or equal than 0xF0 when race stars
byte endRace : 0x2A52D4, 0x0521;	//end of the race. Pretty useless, since variables of proper game time still changing after the moment of finish
byte time :  0x2A52D4,  0x099c;		//1st byte of time game counts by itself
byte sec :  0x2A52D4,  0x099D; 		//2nd byte of time game counts by itself
byte isFinalTime : 0x2A52D4, 0x0997;// 2nd byte of whole track time(even counts after finish)

//byte sec :  0x2A52D4,  0x099D; //proper game time
//byte time :  0x2A52D4,  0x099c;//proper game time
//original address 0x0997;
}

startup{
  settings.Add("Brazil",true);
refreshRate = 100;
vars.counter = 0;//counter to get right split
vars.prevSegmentMin =0;
vars.prevSegmentSec=0;
vars.prevSegmentTenth =0;


vars.currSegmentMin =0;
vars.currSegmentSec=0;
vars.currSegmentTenth =0;
}

start{
 print("prevSegment mins  sec tenth on start" + vars.prevSegmentMin + "-" + vars.prevSegmentSec + "-" + vars.prevSegmentTenth );
vars.prevSegmentMin =0;
vars.prevSegmentSec=0;
vars.prevSegmentTenth =0;


vars.currSegmentMin =0;
vars.currSegmentSec=0;
vars.currSegmentTenth =0;  
  if (current.startRun > 0x0f) return true;
	
}


split{ 
		if (current.endRace==1 && 				  //prevent overheading comparisons
		(current.sec != old.sec)&& 			     //prevent snowball spliting
		(current.isFinalTime != current.sec)  && //skip from split initial final time initialization in secs & time variables
		(current.sec != 0 && current.time !=0))  //
				{ 	
				vars.prevSegmentMin += vars.currSegmentMin;
				vars.prevSegmentSec += vars.currSegmentSec;
				vars.prevSegmentTenth +=vars.currSegmentTenth;
				
				if (vars.prevSegmentTenth >= 10){ vars.prevSegmentTenth -=10; vars.prevSegmentSec++;};
				if (vars.prevSegmentSec >= 60) { vars.prevSegmentSec -=60 ; vars.prevSegmentMin++;}				
				 
				 print("split occured " + vars.prevSegmentMin +"-" + vars.prevSegmentSec +"-" + vars.prevSegmentTenth);
				return true;
				}
}

gameTime{

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
return IGT;
}

update{
//print("min " +current.time.ToString("X") +" sec " + current.sec.ToString("X")  + " startRun " +current.startRun.ToString("X") +" IGT ");
}
