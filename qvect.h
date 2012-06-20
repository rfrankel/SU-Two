/* Object approximating Quaternion Vectors */
/*   Written by Rebecca Frankel            */
#import <objc/Object.h>
#import <tcl.h>
#import <stdio.h>
#import "axang.h"
#define togv stdout

@interface Qvect: Object
{float R;
 float I;
 float J;
 float K;
}

/* Initialize */
-initToZero;
-initWithR:(float)r I:(float)i J:(float)j K:(float)k;

/* Selectors */
-(float)valReal;
-(float)valI;
-(float)valJ;
-(float)valK;

/*  Constructors */
-setReal:(float)num;
-setI: (float)num;
-setJ: (float)num;
-setK: (float)num;
-setR:(float)r I:(float)i J:(float)j K:(float)k;

/*Copying*/
/*As the name suggests*/
/*this is a cluge*/
-stupidCopy;

/*Construct Basic Rotators*/
-(Qvect *)makeExpI:(unsigned)n :(unsigned)m;
-(Qvect *)makeExpJ:(unsigned)n :(unsigned)m;
-(Qvect *)makeExpK:(unsigned)n :(unsigned)m;
-(Qvect *)makeRotatorAxis:(float)x :(float)y :(float)z
                Angle:(unsigned)m :(unsigned)n;
-(Qvect *)rotateAxis:(float)x :(float)y :(float)z
               Angle:(unsigned)n :(unsigned)m;

/* Convert to axis-angle format */
-(AxAng *)makeAa;

/*Operations */
-conj;
-conjD;
-scalarMult:(float)scalar;
-sumWith:(Qvect *)q;
-sumWithD:(Qvect *)q;
-prodWith:(Qvect *)q;
-prodWithD:(Qvect *)q;
-conjBy: (Qvect *)P;
/*Note:default constructs a new object for the result*/
/*"D" stores the result in the second argument*/
/*thus destroying its old value. ("D" = "destroy")*/

/*Print*/
-print;
-printForGVwithName:(char *)name Size:(unsigned)m Col:(char *)col;
-doIncrTransinSteps:(int)n to:(Tcl_Channel)toGv;
-printTransfForGV:(char *)name to:(FILE *)toGv;
-printTransfForChannel:(char *)name to:(Tcl_Channel)toGv;

@end









