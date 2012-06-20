#import "include.h"
#import <tk.h>
#import "gencmds.h"

void gvEventProc(ClientData clientData,int mask);
int transformCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int pickCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int pickNewGvCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);

