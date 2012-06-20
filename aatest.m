#import "axang.h"
#import "aagrp.h"
#import "qvect.h"
#import "group.h"
#import <tcl.h>
static FILE *toNewGv;
static FILE *fromNewGv;

void initEuclGv() {
   static Tcl_Interp *interp;     
   int argc,code,*pidPtr,inPipe,outPipe;
   char **argv; 

  fflush(togv);
  code = Tcl_SplitList(interp,"gv -c - -nopanels -wpos 180,180@200,200 >&2",
            &argc,&argv);
  Tcl_CreatePipeline(interp,argc,argv,&pidPtr,&inPipe,&outPipe,(int)NULL);
  toNewGv = fdopen(inPipe,"w");
  fromNewGv = fdopen(outPipe,"r");
  fprintf(toNewGv,"(backcolor focus .54 .443 .575)\n");
  fprintf(toNewGv,"(merge camera \"Camera\" {perspective 0})\n");
  fflush(toNewGv); fflush(togv);  
}

void main() {
  AaGrp *aagrp;
  Group *Qgrp;
  
  initEuclGv();
  aagrp = [[AaGrp alloc] init];
  [aagrp makeAaGrpFromOff:"off/tetra.off"];
//  [aagrp print];
  [aagrp printForEuclGV:stdout];
  Qgrp = [[Group alloc] init];
  [aagrp convertAaGrpTo:Qgrp];
//  [Qgrp printForEuclGV:stdout];
//  [Qgrp print];
//  [Qgrp printForGVwithSize:35];
}  
  
int groupCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv){
   return TCL_OK;
   }

int qvectCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv){
   return TCL_OK;
   }



