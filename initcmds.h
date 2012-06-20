#import "include.h"
#import "comcmds.h"
#import <tk.h>
#define GCsize 96

int initCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
void initGV(Decor *decor);
void drawGCs(Decor *decor);
void initEuclGv(Tcl_Interp *interp);
