/* Color object */
/* Written by Rebecca Frankel */
#import "rgb.h"
#import <stdlib.h>

@implementation RGB

-initWithR:(float)red G:(float)green B:(float)blue {

 R = red; G = green; B = blue;
 return self;
}

-initWithIntR:(float)red G:(float)green B:(float)blue {

 R = red/256; G = green/256; B = blue/256;
 return self;
}

-setR:(float)red {
 R = red;
 return self;
}

-setG:(float)green {
 G = green;
 return self;
}

-setB:(float)blue {
 B = blue;
 return self;
}

-(float)valR {
 return R;
}

-(float)valG {
 return G;
}

-(float)valB {
 return B;
}

-(char *)valRGB {
  char *str;

  str = (char *)malloc(20*(sizeof(char)));
  sprintf(str," %5f %5f %5f ",R,G,B);
  return str;
}

-print {
 printf("Red: %f   Green: %f    Blue: %f",R,G,B);
 return self;
}

@end