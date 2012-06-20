#import "initcmds.h"
extern Tcl_Channel toNewGv;
/*extern FILE *fromNewGv;*/
Decor *basicDecor;
    
int initCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
  Qlongt *diag;

  basicDecor = [[Decor alloc] initIn:interp Name:"basicDecor"];
  [basicDecor makeDecorFromFile:"standard.rgb"];
  diag = [[[Qlongt alloc] initWithSize:48] makeDiagLongtIn:interp]; 

  initGV(basicDecor);
  drawGCs(basicDecor);
  /* special case: all three ribs are the same color; inform Tcl */
   Tcl_SetVar2(interp,"color","ijGrCirc","eq_ribs",TCL_GLOBAL_ONLY);
   Tcl_SetVar2(interp,"color","jkGrCirc","eq_ribs",TCL_GLOBAL_ONLY);
   Tcl_SetVar2(interp,"color","ikGrCirc","eq_ribs",TCL_GLOBAL_ONLY);
   initEuclGv(interp);

  /*register interest in pick commands*/
  printf("(interest (pick world * nil nil nil nil nil nil nil nil))\n");

  return TCL_OK;
}

void initGV(Decor *decor) {
 char *camcol,*confcol,*light1,*light2,*light3; 
 char *l1pos,*l2pos,*l3pos;

 camcol = [decor findFaceRGBforKey:"Camera"];
 confcol = [decor findFaceRGBforKey:"ConformalCam"];
 light1 = [decor findFaceRGBforKey:"light1"];
 l1pos = [decor findEdgeRGBforKey:"light1"];
 light2 = [decor findFaceRGBforKey:"light2"];
 l2pos = [decor findEdgeRGBforKey:"light2"];
 light3 = [decor findFaceRGBforKey:"light3"];
 l3pos = [decor findEdgeRGBforKey:"light3"];
 fprintf(togv,"(space spherical)\n");
 fprintf(togv,"(backcolor \"Camera\" %s)\n",camcol);
 fprintf(togv,"(read camera {define c1 perspective 0})\n");
 fprintf(togv,"(new-camera ConformalCam {:c1})\n");
 fprintf(togv,"(space spherical)\n"); /*to new camera*/
 fprintf(togv,"(hmodel ConformalCam conformal)\n");
 fprintf(togv,"(hsphere-draw ConformalCam no)\n");
 fprintf(togv,"(backcolor ConformalCam %s)\n",confcol);
 fprintf(togv,"(transform g0 g0 universe rotate 0 1.5707 0)");
 fprintf(togv,"(transform g0 g0 universe rotate 3.14159 0 0)");
 fprintf(togv,"(merge-baseap appearance {lighting {replacelights ");
 fprintf(togv,"light {color %s",light1);
 fprintf(togv,"position %s 0.0}",l1pos);
 fprintf(togv,"light {color %s",light2);
 fprintf(togv,"position %s 0.0}",l2pos);
 fprintf(togv,"light {color %s",light3);
 fprintf(togv,"position %s 0.0}}})",l3pos);
 fflush(togv);
}

void drawGCs(Decor *decor) {
  Qlongt *Diag,*jL,*kL,*Theta,*ijL, *ikL;
  char *eq,*eqribs;

  eq = [decor findEdgeRGBforKey:"equator"];
  eqribs = [decor findFaceRGBforKey:"eq_ribs"];

  Diag = [[Qlongt alloc] initWithSize: GCsize];
  jL = [[Qlongt alloc] initWithSize: GCsize];
  kL  = [[Qlongt alloc] initWithSize: GCsize];
  Theta =[[Qlongt alloc] initWithSize: GCsize];
  ijL  = [[Qlongt alloc] initWithSize: GCsize];
  ikL = [[Qlongt alloc] initWithSize: GCsize];
  
  Diag = [Diag makeDiagLongt];
  jL = [jL makeJLongt];
  kL = [kL makeKLongt];
  Theta = [Theta makeJKGrCirc:0];
  ijL = [ijL makeIJGrCirc:0];
  ikL= [ikL makeIKGrCirc:0];

  fprintf(togv,"(progn\n");
    
  [Diag printForGV:"diagLongt"];
  [jL printForGV:"jLongt"];
  [kL printForGV:"kLongt"];
  [Theta printForGVwithWidth:"jkGrCirc" Col:eqribs];
  [ijL printForGVwithWidth:"ijGrCirc" Col:eqribs];
  [ikL printForGVwithWidth:"ikGrCirc" Col:eqribs];
  fprintf(togv,"(read geometry {define eq_ribs {LIST");
  fprintf(togv," {:ijGrCirc} {:jkGrCirc} {:ikGrCirc}}})");
  fprintf(togv,"(geometry eq_ribs {:eq_ribs})");
  fprintf(togv,"(delete jkGrCirc)");
  fprintf(togv,"(delete ijGrCirc)");
  fprintf(togv,"(delete ikGrCirc)");

  [ijL printSphereRhoRotations:"equator" numL:10 Col:eq];
  fprintf(togv,")\n");
  fflush(stdout);

  Diag = [Diag free];   Theta = [Theta free];
  jL = [jL free];      ijL = [ijL free];
  kL = [kL free];      ikL = [ikL free];
}

void initEuclGv(Tcl_Interp *interp) {
   extern Tcl_Channel toNewGv;
   /*extern FILE *fromNewGv;*/

   int argc,code; 
   char **argv; 

  fflush(togv);
  code = Tcl_SplitList(interp,"geomview -c - -nopanels -wpos 320,320@50,50",
            &argc,&argv);
  toNewGv = Tcl_OpenCommandChannel(interp,argc,argv,TCL_STDIN);
  /*toNewGv = fdopen(inPipe,"w");*/
  /* fromNewGv = fdopen(outPipe,"r");*/
  /*Tcl_CreateFileHandler(fileno(fromNewGv), TK_READABLE, gvEventProc,
    (ClientData) interp); */
  Tcl_Write(toNewGv,"(backcolor focus .54 .443 .575)\n",-1);
  Tcl_Write(toNewGv,"(merge camera \"Camera\" {perspective 0})\n",-1);
  Tcl_Flush(toNewGv); fflush(togv); 
}









