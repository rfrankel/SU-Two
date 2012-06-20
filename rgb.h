/* Color object */
/* Written by Rebecca Frankel */
#import <objc/Object.h>

@interface RGB : Object
{
  float R;
  float G;
  float B;
}

/* Init */
-initWithR:(float)red G:(float)green B:(float)blue;
-initWithIntR:(float)red G:(float)green B:(float)blue;

/* Set */
-setR:(float)red;
-setG:(float)green;
-setB:(float)blue;

/* Get values */
-(float)valR;
-(float)valG;
-(float)valB; 
-(char *)valRGB;

/*Print */
-print;

@end
