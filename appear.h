/* Appearance object */
/* Written by Rebecca Frankel */
#import <objc/Object.h>

#define OBJ 0
#define LIGHT 1
#define CAM 2

@interface App : Object
{
  int Type;
  float Face;  /*0=off, 0<F<1 transparent, 1=opaque*/
  char *FaceRGB;
  int Edge;    /*0=off, values >=1 mean width*/
  char *EdgeRGB;
}

/* Init */
-init;
-initWithFaceRGB:(char *)fRGB;
-initWithEdgeRGB:(char *)eRGB;
-initWithF:(float)f FaceRGB:(char *)fRGB E:(int)e EdgeRGB:(char *)eRGB;

/* Set */
-setType:(int)type;
-setF:(float)face;
-setFColor:(char *)faceRGB;
-setE:(int)edge;
-setEColor:(char *)edgeRGB;

/* Get values */
-(int)valType;
-(float)valF;
-(char *)valFColor;
-(int)valE;
-(char *)valEColor;

/* Copy */
-copy;

/* Print */
-print:(FILE *)file;
-printForGv:(char *)key;
-printForGv:(char *)key To:(FILE *)toGv;
@end
