/* Axis and Angle object */
/* Written by Rebecca Frankel */
#import <objc/Object.h>
#import <tcl.h>

@class Qvect;
@class Qlongt;

@interface AxAng : Object
{
  float X;
  float Y;
  float Z;
  float pX; /* "perpendicular direction" */
  float pY; /* used for indicating angle graphically */
  float pZ;
  float Ang; 
  int AngTypeFlag;
}

/* Init */
-initWithAxisX:(float)x Y:(float)y Z:(float)z Ang:(float)n;
-initWithAxisX:(float)x Y:(float)y Z:(float)z Index:(int)n;

/* Set */
-setX:(float)x Y:(float)y Z:(float)z;
-setpX:(float)x pY:(float)y pZ:(float)z;
-addtopX:(float)x pY:(float)y pZ:(float)z;
-setAng:(float)n;


/* Get values */
-(float)valX;
-(float)valY;
-(float)valZ;
-(float)valpX;
-(float)valpY;
-(float)valpZ;
-(float)valAng;
-(int)valInd;


/* Operations */
-(Qvect *)convertToQ;
-(Qvect *)rotateQv:(Qvect *)qv;
-(Qlongt *)rotateQl:(Qlongt *)ql;

/*Print */
-printTransForGV:(char *)name to:(Tcl_Channel)toGv;

@end




