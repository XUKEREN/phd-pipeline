/*center by mean*/
proc means data=chs noprint; 
by tempid; 
var ht; 
output out=meanout mean=meanht;
data chs; 
merge meanout chs; 
by tempid; 
centht = ht-meanht; run;
