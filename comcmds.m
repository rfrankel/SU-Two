#import "comcmds.h"
static Tcl_DString command;

extern int read _ANSI_ARGS_((int fd, char *buf, size_t size));
int doPoint(Qvect *qv, Tcl_Interp *interp);

int transformCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    float e[16];
    Qvect *qv;

    if (argc != 2) {
         interp->result = "wrong # args for transform";
         return TCL_ERROR;
    }

   if (sscanf(argv[1],"%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f"
       ,&e[0],&e[1],&e[2], &e[3],&e[4],&e[5],&e[6],&e[7],&e[8]
       ,&e[9],&e[10], &e[11],&e[12],&e[13],&e[14],&e[15]) == EOF) {
             fprintf(stderr,"Error reading transform(2)");
   }
       
 /*entries backwards because CS matrices are */
 /*the transform of math matrices */
   qv = [[Qvect alloc] initWithR:e[15] I:e[14] J:e[13] K:e[12]];
    doPoint(qv,interp);
    return TCL_OK;  
}    

int pickCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {

    if (argc != 11) {
         interp->result = "wrong # args for pick";
         return TCL_ERROR;
    }

    fprintf(togv,"(write transform - ptr world)\n");
    fflush(togv);
    return TCL_OK;
}

int pickNewGvCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    char script[15];
    int code;

    if (argc != 11) {
         interp->result = "wrong # args for pick";
         return TCL_ERROR;
    }

    if (strlen(argv[2])>2) {
      fprintf(togv,"(if (real-id %s)",argv[2]);
      fprintf(togv,"(merge-ap %s appearance { *+face material {",argv[2]);
      fprintf(togv,"*ambient 0.0784 0.0784 0.9019");
      fprintf(togv," *diffuse 0.0784 0.0784 0.9019}}))");
      fflush(togv);
      sprintf(script,".g.%s select",argv[2]);
      code = Tcl_Eval(interp,script);
      sprintf(interp->result,"%s",argv[2]);
    } 
    return TCL_OK;
}

void gvEventProc(clientData, mask)
    ClientData clientData;              /* Passes interpreter */
    int mask;                           /* Not used. */
{
  /*
    #define BUFFER_SIZE 4000
    char input[BUFFER_SIZE+1];
    static int gotPartial = 0;
    char *cmd,*pos,script[50];
    int code, count;
    Tcl_Interp *interp;

    interp = (Tcl_Interp *)clientData;
    count = read(fileno(fromNewGv), input, BUFFER_SIZE);
    if (count <= 0) { 
        if (!gotPartial) {
                fprintf(stderr,"Error in GV filehandler");
                Tk_DeleteFileHandler(fileno(fromNewGv));
                 return;
        } else {
            count = 0;
        }
    }   

    cmd = Tcl_DStringAppend(&command, input, count);
    if (count != 0) {
        if ((input[count-1] != '\n') && (input[count-1] != ';')) {
            gotPartial = 1;
            return;
        }
        if (!Tcl_CommandComplete(cmd)) {
            gotPartial = 1;
            return;
        }
    }
    gotPartial = 0;

    * Commands recieved from Geomview may have "(" or ")"
     * we want to convert these to "{" and "}" so they won't
     * confuse Tcl_Eval. (isn't it a cute idea to convert
     * Geomview commands to Tcl commands? Due to Stuart Levy.)
     *

     pos = cmd;
     if (*pos == '(') {
            *pos = ' '; * remove enclosing "("*
            *pos = strrchr(cmd,')');
            *pos = ' '; * remove other ")" *
            *pos = cmd++;
       } 
     while(*pos != '\0') {
       if (*pos == '(') *pos = '{';
       if (*pos == ')') *pos = '}';
       pos++;
     }

    * cmd may have been a Geomview command like (pick ...) *
    * which is now {pick ...}. We need to remove the enclosing *
    * {} -- which we can do conceptually by considering it a tcl *
    * list and extracting the first element. *
 
*    Tcl_SetVar(interp,"cmd",(char *)cmd,TCL_GLOBAL_ONLY);
    sprintf(script,"if {llength %s = 1}",cmd);
    sprintf(script,"%s {set cmd [lindex %s 0]}",script,cmd);
    code = Tcl_Eval(interp,script);
    pos = Tcl_GetVar(interp,"cmd",TCL_GLOBAL_ONLY);
    strcpy(cmd,pos);    *

    *
     * Disable the stdin file handler while evaluating the  command;
     * otherwise if the command re-enters the event loop we might
     * process commands from stdin before the current command is
     * finished.  Among other things, this will trash the text of the
     * command being evaluated.
     *
    
    Tk_CreateFileHandler(0, 0, gvEventProc, (ClientData)interp);
    code = Tcl_Eval(interp, cmd);
    Tk_CreateFileHandler(0, TK_READABLE, gvEventProc, (ClientData)interp);
    Tcl_DStringFree(&command);
    
    if (*interp->result != 0) {
        if (code != TCL_OK) {
            fprintf(stderr,"%s\n", interp->result);
        }
    }*/
}








