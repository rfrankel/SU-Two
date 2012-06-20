/* Appearance object */
/* Written by Rebecca Frankel */
#import "appear.h"
#import <stdlib.h>

@implementation App

-init {
  Type = OBJ;
  Face = 0;  FaceRGB = " 1 1 1 ";
  Edge = 1;  Edge = " 0 0 0 ";
  return self;
}

-initWithFaceRGB:(char *)fRGB {
  Type = OBJ;
  Face = 1;  FaceRGB = fRGB;
  Edge = 0;  Edge = " 0 0 0 ";
  return self;
}

-initWithEdgeRGB:(char *)eRGB {
  Type = OBJ;
  Face = 0;  FaceRGB = " 1 1 1 ";
  Edge = 1;  Edge = eRGB;
  return self;
}

-initWithF:(float)f FaceRGB:(char *)fRGB E:(int)e EdgeRGB:(char *)eRGB {
  Type = OBJ;
  Face = f;  FaceRGB = fRGB;
  Edge = e;  EdgeRGB = eRGB;
  return self;
}

-setType:(int)type {
 Type = type;
 return self;
}

-setF:(float)face {
 Face = face;
 return self;
}

-setFColor:(char *)faceRGB {
 FaceRGB = faceRGB;
 return self;
}

-setE:(int)edge {
 Edge = edge;
 return self;
}

-setEColor:(char *)edgeRGB {
 EdgeRGB = edgeRGB;
 return self;
}

-(int)valType {
 return Type;
}

-(float)valF {
 return Face;
}

-(char *)valFColor {
 return FaceRGB;
}

-(int)valE {
 return Edge;
}

-(char *)valEColor {
 return EdgeRGB;
}

-(char *)valRGB{
  char *str;

  str = (char *)malloc(20*(sizeof(char *)));
  sprintf(str," %5f %5f %5f ",R,G,B);
  return str;
}

-print:(FILE *)file {
 fprintf(file,"%f Face %s",Face,FaceRGB);
 fprintf(file,"%d Edge %s",Edge,EdgeRGB);
 return self;
}

@end