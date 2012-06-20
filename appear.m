/* Appearance object */
/* Written by Rebecca Frankel */
#import "appear.h"
#import <stdlib.h>
#import "include.h"

@implementation App

-init {
  Type = OBJ;
  Face = 0;  FaceRGB = " 1 1 1 ";
  Edge = 1;  EdgeRGB = " 0 0 0 ";
  return self;
}

-initWithFaceRGB:(char *)fRGB {
  Type = OBJ;
  Face = 1;  FaceRGB = fRGB;
  Edge = 0;  EdgeRGB = " 0 0 0 ";
  return self;
}

-initWithEdgeRGB:(char *)eRGB {
  Type = OBJ;
  Face = 0;  FaceRGB = " 1 1 1 ";
  Edge = 1;  EdgeRGB = eRGB;
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

-copy {
  App *newApp;
  float f; int e;
  char *fc,*ec;
  
  f = [self valF]; e = [self valE];
  fc = [self valFColor]; ec = [self valEColor];
  newApp = [[App alloc] initWithF:f FaceRGB:fc E:e EdgeRGB:ec];
  [newApp setType:[self valType]];
  return newApp;
}

-print:(FILE *)file {
 fprintf(file,"%f Face %s\n",Face,FaceRGB);
 fprintf(file,"%d Edge %s\n",Edge,EdgeRGB);
 return self;
}

-printForGv:(char *)key {
     char *camstuff;
     float fov,near,far; 

     fprintf(togv,"(progn");
     switch (Type) {
      case 0: /*OBJ*/
         if (Face == 1) {
           fprintf(togv,"(if (real-id %s)",key); 
           fprintf(togv,"(merge-ap %s appearance {+face -transparent",key);  
           fprintf(togv," material {ambient %s",FaceRGB);
           fprintf(togv," diffuse %s}})\n",FaceRGB);
           fprintf(togv,")\n");
           /* killed the overrides shown below*/
	   /* fprintf(togv,"(if (real-id %s)",key); 
           fprintf(togv,"(merge-ap %s appearance {*+face *-transparent",key);  
           fprintf(togv," material {*ambient %s",FaceRGB);
           fprintf(togv," *diffuse %s}})\n",FaceRGB);
           fprintf(togv,")\n");*/
           fflush(togv);
         }
         if (Face == 0) {
           fprintf(togv,"(if (real-id %s)",key); 
           fprintf(togv,"(merge-ap %s appearance {*-face})\n",key);
           fprintf(togv,")\n");
           }
         if (Face>0 && Face<1) {
           fprintf(togv,"(if (real-id %s)",key); 
           fprintf(togv,"(merge-ap %s appearance {*+face *+transparent",key);
           fprintf(togv," material {*ambient %s",FaceRGB);
           fprintf(togv," *diffuse %s *alpha %f}})\n",FaceRGB,Face);
           fprintf(togv,")\n");
         }
         if (Edge == 0) {
           fprintf(togv,"(if (real-id %s)",key); 
           fprintf(togv,"(merge-ap %s appearance {*-edge})\n",key);
           fprintf(togv,")\n");
         }
         if (Edge >= 1) {
           fprintf(togv,"(if (real-id %s)",key); 
           fprintf(togv,"(merge-ap %s appearance {*+edge ",key);
       fprintf(togv,"linewidth %d material {*edgecolor %s}})\n",Edge,EdgeRGB); 
           fprintf(togv,")\n");
         }
         break;
      case 1: /*LIGHT*/
           fprintf(togv,"(merge-baseap appearance {lighting { ");
           fprintf(togv,"light {color %s",FaceRGB);
           fprintf(togv,"position %s 0.0}",EdgeRGB);          
         break;
      case 2: /*CAM*/
         if (Face>0) { 
           fprintf(togv,"(backcolor %s %s)\n",key,FaceRGB);
         }
         if (Edge>0) {
           fprintf(togv,"(merge camera %s camera {",key);
           camstuff = EdgeRGB;
           sscanf(camstuff," %f %f %f ",&fov,&near,&far);
           fprintf(togv,"fov %f near %f far %f})",fov,near,far);
         }
         break;
      default:
         fprintf(stderr,"Type is %d\n",Type);     
     }
     fprintf(togv,")");
     fflush(togv);
     return self;
}

-printForGv:(char *)key To:(FILE *)toGv {
     char *camstuff;
     float fov,near,far; 

     fprintf(toGv,"(if (real-id %s)",key); 
     switch (Type) {
        case 0: /*OBJ*/ 
         if (Face == 1) {
           fprintf(toGv,"(merge-ap %s appearance {*+face *-transparent",key);  
           fprintf(toGv," material {*ambient %s",FaceRGB);
           fprintf(toGv," *diffuse %s}})",FaceRGB);
           fflush(toGv);
         }
         if (Face == 0) {
           fprintf(toGv,"(merge-ap %s appearance {*-face})",key);
           }
         if (Face>0 && Face<1) {
           fprintf(toGv,"(merge-ap %s appearance {*+face *+transparent",key);
           fprintf(toGv," material {*ambient %s",FaceRGB);
           fprintf(toGv," *diffuse %s *alpha %f}})",FaceRGB,Face);
         }
         if (Edge == 0) {
           fprintf(toGv,"(merge-ap %s appearance {*-edge})",key);
         }
         if (Edge >= 1) {
           fprintf(toGv,"(merge-ap %s appearance {*+edge ",key);
          fprintf(toGv,"linewidth %d material {edgecolor %s}})",Edge,EdgeRGB); 
         }
         break;
        case 1: /*LIGHT*/
           fprintf(toGv,"(merge-baseap appearance {lighting { ");
           fprintf(toGv,"light {color %s",FaceRGB);
           fprintf(toGv,"position %s 0.0}",EdgeRGB);          
         break;
        case 2: /*CAM*/
         if (Face>0) { 
           fprintf(toGv,"(backcolor %s %s)\n",key,FaceRGB);
         }
         if (Face>0) {
           fprintf(toGv,"(merge camera %s camera {",key);
           camstuff = EdgeRGB;
           sscanf(camstuff," %f %f %f ",&fov,&near,&far);
           fprintf(toGv,"fov %f near %f far %f})",fov,near,far);
         }
         break;
     }
     fprintf(toGv,")");
     fflush(toGv);
     return self;
}

@end


