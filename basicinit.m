#import "basicinit.h"
#import <tcl.h>

char baseap[] = "(merge-baseap appearance {\
 lighting {\
        ambient 0.2 0.2 0.2\
        localviewer 1\
        attenconst 0\
        attenmult 0\
        replacelights\
        light {\
                ambient 0.000000 0.000000 0.000000\
                color 0.461861 0.016182 0.296779\
                position -5.113719 -1.405946 8.477798 0.000000\
        }\
        light {\
                ambient 0.000000 0.000000 0.000000\
		color 0.784661 0.000000 0.929062\
                position 0.338036 1.347794 -0.263028 0.000000\
        }\
        light {\
                ambient 0.000000 0.000000 0.000000\
                color 0.184124 0.087800 0.919527\
                position 1.000000 -2.000000 -1.000000 0.000000\
        }\
  }\
}\
)";

char sphereap[] = "(merge-ap \"rhoSphere\" appearance {\
        * face\
        * transparent\
        *  shading smooth\
  material {\
        *shininess 12.733691\
        *ka 0.461861\
        *kd 1.000000\
        *ks 0.374582\
        *alpha 0.328375
        ambient 0.651197 0.763969 1.000000\
        *diffuse 0.651197 0.763969 1.000000\
  }\
}\
)";

void main() {
  initGV();
  drawGCs();
}

void initGV() {

 fprintf(togv,"(space spherical)\n");
 fprintf(togv,"(backcolor \"Camera\" 0.165932 0.628321 0.607799)\n");
 fprintf(togv,"(read camera {define c1 perspective 0})\n");
 fprintf(togv,"(new-camera ConformalCam {:c1})\n");
 fprintf(togv,"(space spherical)\n"); /*to new camera*/
 fprintf(togv,"(hmodel ConformalCam conformal)\n");
 fprintf(togv,"(hsphere-draw ConformalCam no)\n");
 fprintf(togv,"(backcolor ConformalCam .327 .28 .39)\n");
 fprintf(togv,"(transform g0 g0 universe rotate 0 1.5707 0)");
 fprintf(togv,"(transform g0 g0 universe rotate 3.14159 0 0)");
 fprintf(togv,"%s",baseap);
 fflush(togv);
}
   
void drawGCs() {
  Qlongt *Diag,*jL,*kL,*Theta,*ijL, *ikL;

  Diag = [[Qlongt alloc] initWithSize: GCsize];
  jL = [[Qlongt alloc] initWithSize: GCsize];
  kL  = [[Qlongt alloc] initWithSize: GCsize];
  Theta =[[Qlongt alloc] initWithSize: GCsize];
  ijL  = [[Qlongt alloc] initWithSize: GCsize];
  ikL = [[Qlongt alloc] initWithSize: GCsize];
  
  Diag = [Diag makeDiagLongt];
  jL = [jL makeJLongt];
  kL = [kL makeKLongt];
  Theta = [Theta makeJKGrCirc];
  ijL = [ijL makeIJGrCirc];
  ikL= [ikL makeIKGrCirc];

  fprintf(togv,"(progn\n");
    
  [Diag printForGV:"diagLongt"];
  [jL printForGV:"jLongt"];
  [kL printForGV:"kLongt"];
  [Theta printForGVwithWidth:"thetaGrCirc"];
  [ijL printForGVwithWidth: "ijGrCirc"];
  [ikL printForGVwithWidth: "ikGrCirc"];

  [ijL printSphereRhoRotations:"rhoSphere" numL:10];
  fprintf(togv,")\n");
  fflush(stdout);

  Diag = [Diag free];   Theta = [Theta free];
  jL = [jL free];      ijL = [ijL free];
  kL = [kL free];      ikL = [ikL free];
}


int groupCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv){
   return TCL_OK;
   }

int qvectCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv){
   return TCL_OK;
   }






