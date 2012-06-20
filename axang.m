/* Axis and Angle object */
/* Written by Rebecca Frankel */

#import "axang.h"
#import "qvect.h"
#import "qlongt.h"
#import <math.h>

#define PI 3.14159

#define INDEX 0
#define FLOAT 1
#define RADIANS 2
#define DEGREES 3

@implementation AxAng

-initWithAxisX:(float)x Y:(float)y Z:(float)z Ang:(float)n {
   float sumsq;
   
   /* normalize x,y,z*/
   sumsq = sqrt(x*x + y*y + z*z);
   x= x/sumsq; y= y/sumsq; z= z/sumsq;
   X = x; Y = y; Z = z; Ang = n;  
   pX = x; pY = y; pZ = z;
   AngTypeFlag = FLOAT; 
   return self;
}

-initWithAxisX:(float)x Y:(float)y Z:(float)z Index:(int)n {

   X = x; Y = y; Z = z; Ang = (float)n;  
   pX = x; pY = y; pZ = z;
   AngTypeFlag = INDEX; 
   return self;
}

-setX:(float)x Y:(float)y Z:(float)z {
   X = x; Y = y; Z = z;
   pX = x; pY = y; pZ = z;
   return self;
}

-setpX:(float)x pY:(float)y pZ:(float)z {
   pX = x; pY = y; pZ = z;
   return self;
}

-addtopX:(float)x pY:(float)y pZ:(float)z {
   pX = pX + x; pY = pY + y; pZ = pZ + z;
   return self;
}

-setAng:(float)n {
   Ang = n; 
   AngTypeFlag = FLOAT;
   return self;
}

-(float)valX {
   return X;
}

-(float)valY {
   return Y;
}

-(float)valZ {
   return Z;
}

-(float)valpX {
   return pX;
}

-(float)valpY {
   return pY;
}

-(float)valpZ {
   return pZ;
}


-(float)valAng {
   return Ang;
}

-(int)valInd {
   return (int)Ang;
}


-(Qvect *)convertToQ {
   float theta,sth,x,y,z,sumsq;   
   Qvect *Rtr;

   theta = Ang/2;
   sth = sin(theta);
   sumsq = sqrt(X*X + Y*Y + Z*Z);
   x= X/sumsq; y= Y/sumsq; z= Z/sumsq;
   x = sth*x; y = sth*y; z = sth*z;
   Rtr = [[Qvect alloc] initWithR:cos(theta) I:x J:y K:z];
   return Rtr;
}

-(Qvect *)rotateQv:(Qvect *)qv {
   Qvect *Rtr,*answer;
 
   Rtr = [self convertToQ];
   answer = [qv conjBy: Rtr];
   [Rtr free];
   return answer;
}

-(Qlongt *)rotateQl:(Qlongt *)ql {
   int j,numElements;
   Qvect *qvj,*Rtr,*newqv;
   Qlongt *newQl;
  
  numElements = ql->numElements;
  newQl = [[Qlongt alloc] initWithSize:numElements]; 
  Rtr = [self convertToQ]; /*for efficiency*/
  for (j=0; j<numElements; j++) {
     qvj = [ql getQatVertD: j];   
     newqv = [qvj conjBy: Rtr];
     [newQl addQ: newqv];
   } 
  return newQl;
}


-printTransForGV:(char *)name to:(Tcl_Channel)toGv {
     /* formula from Graphic Gems after I made a messy 
        and inaccurate attempt to compute it myself */
     /* Assumes Ang is in FLOAT form */
  float t,s,c,sumsq,x,y,z; 
  char temp[300];
   
   /* normalize x,y,z*/
   sumsq = sqrt(X*X + Y*Y + Z*Z);
   x= X/sumsq; y= Y/sumsq; z= Z/sumsq;
  s = sin(Ang); c = cos(Ang); t = 1 - cos(Ang);
  sprintf(temp,"(read transform {transform define t%s ",name);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*x*x + c);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*x*y - s*z);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*x*z + s*y);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 0.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*x*y + s*z);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*y*y + c);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*y*z - s*x);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 0.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*x*z - s*y);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*y*z + s*x);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", t*z*z + c);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 0.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 0.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 0.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 0.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"%f ", 1.0);
   Tcl_Write(toGv, temp,-1);
  sprintf(temp,"})\n"); 
   Tcl_Write(toGv, temp,-1);
  Tcl_Flush(toGv);
  return self;
}


@end






