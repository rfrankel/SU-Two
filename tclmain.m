#import "include.h"
#include <tk.h>
#include <tcl.h>
#import "initcmds.h"
#import "comcmds.h"
#import "gencmds.h"
#import "objcmds.h"
//extern int main();

Group *points = NULL;
Tcl_Channel toNewGv = NULL;

//int *tclDummyMainPtr = (int *) main;
/* These last incantations directed by the Tcl Book (page 307) */

int Tcl_AppInit(Tcl_Interp *interp) {

    if (Tcl_Init(interp) == TCL_ERROR)
        return TCL_ERROR;
    if (Tk_Init(interp) == TCL_ERROR)
        return TCL_ERROR;

    Tcl_CreateCommand(interp, "init", initCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "initGrp", initGrpCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "listGroup", listGrpCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "killGroup", killGrpCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "progn", prognCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "endprogn", endprognCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "removeFromGv", removeFromGvCmd,
                         (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "faceOff", faceOffCmd,
                         (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);


    Tcl_CreateCommand(interp, "transform", transformCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "pick", pickNewGvCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "(pick", pickCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);

    Tcl_CreateCommand(interp, "markPoint", markPointCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "unmarkPoint", unMarkPointCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "turnAndMark", turnAndMarkCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);

 Tcl_SetVar(interp,"tcl_rcFileName","main.tcl",TCL_GLOBAL_ONLY);
 /*    tcl_RcFileName = "main.tcl";  Old 7.4 API */

    return TCL_OK;
}

int main(int argc, char **argv)
{
    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;
}
































































