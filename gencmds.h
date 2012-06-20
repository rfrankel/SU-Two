#import "include.h"
#import "objcmds.h"

int initGrpCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int listGrpCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int prognCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int endprognCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int doPoint(Qvect *qv, Tcl_Interp *interp);
int undoPoint(char *name, Tcl_Interp *interp); 
int killGrpCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int faceOffCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int removeFromGvCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv); 
int markPointCmd(ClientData clientData, Tcl_Interp *interp,
                     int argc, char **argv);
int unMarkPointCmd(ClientData clientData, Tcl_Interp *interp,
                         int argc, char **argv);
int turnAndMarkCmd(ClientData clientData, Tcl_Interp *interp,
                     int argc, char **argv);
int printForGV(Tcl_Interp *interp, char *grptype,
                             Group *group, int size);

