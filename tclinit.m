#include "tcl.h"
#include "tk.h"
#include <stdio.h>
#include <string.h>
#import "group.h"
#import "qvect.h"
extern int main();
int *tclDummyMailPtr = (int *) main;
/* These last incantations directed by the Tcl Book (page 307) */
static Group *points;
static int counter;
static Tcl_DString command;
static Tcl_Interp *interp;
#define togv stdout     

void tetraInEuclGv();
void initEuclGv();
extern int read _ANSI_ARGS_((int fd, char *buf, size_t size));
static void gvEventProc(ClientData clientData,int mask);
int doPoint(Qvect *qv, Tcl_Interp *interp);
int undoPoint(char *name, Tcl_Interp *interp); 


/*Processes Geomview's transform data*/
/*Returns list of last four transform entries */
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

int groupCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    Group *group;
    Qvect *qv1,*qv2, *prod;


    group = (id) clientData;
    if (argc < 2) {
         interp->result = "too few args";
         return TCL_ERROR;
    }

    if (strcmp(argv[1],"name") == 0) {
       sprintf(interp->result,"%s",argv[0]);
    } else if (strcmp(argv[1],"list") == 0) {
       [group listGrp];
    } else if (strcmp(argv[1],"delete") == 0) {
         if (argc != 3) {
             interp->result = "wrong # of args";
             return TCL_ERROR;
         }
       undoPoint(argv[2],interp);
    } else if (strcmp(argv[1],"multiply") == 0 ||
                   strcmp(argv[1],"conjugate")== 0) {
         if (argc != 5) {
             interp->result = "wrong # of args";
             return TCL_ERROR;
         }
       qv1 = [points findQforKey:argv[2]];
       qv2 = [points findQforKey:argv[4]];
       if (strcmp(argv[1],"multiply") == 0) prod = [qv1 prodWith: qv2];
       if (strcmp(argv[1],"conjugate") == 0) prod = [qv1 conjBy: qv2];
       doPoint(prod, interp);
    } else {
       Tcl_AppendResult(interp, "bad group command \"",
             argv[1],"\": should be name or list", (char *)NULL);
       return TCL_ERROR;
    }
    return TCL_OK;
}

int qvectCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    Qvect *qv;

    qv = (id) clientData;
    if (argc != 2) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }

    if (strcmp(argv[1],"name") == 0) {
       sprintf(interp->result,"%s",argv[0]);
    } else if (strcmp(argv[1],"valR") == 0) {
       sprintf(interp->result,"%f",[qv valReal]);
    } else if (strcmp(argv[1],"valI") == 0) {
       sprintf(interp->result,"%f",[qv valI]);
    } else if (strcmp(argv[1],"valJ") == 0) {
       sprintf(interp->result,"%f",[qv valJ]);
    } else if (strcmp(argv[1],"valK") == 0) {
       sprintf(interp->result,"%f",[qv valK]);
    } else {
       Tcl_AppendResult(interp, "bad quaternion command \"",
             argv[1],"\": should be name or list", (char *)NULL);
       return TCL_ERROR;
    }
    return TCL_OK;
}

int doPoint(Qvect *qv, Tcl_Interp *interp) {
    char name[10],script[250],*namecopy;    
    int red,code;

    sprintf(name,"point%d",counter);
    red = (20 + 30*counter)%256;  
    sprintf(script,"radiobutton .l%s -text %s",name,name);
    sprintf(script,"%s -variable pt1  -value %s\n",script,name);
sprintf(script,"%s pack .l%s -in .top.left -side top -fill x\n",script,name); 
    sprintf(script,"%s radiobutton .r%s -text %s",script,name,name);
    sprintf(script,"%s -variable pt2  -value %s\n",script,name);
sprintf(script,"%s pack .r%s -in .top.right -side top -fill x\n",script,name); 


  /*Put point in group table*/
    namecopy = strdup(name);
    [points insertQ:qv Key:namecopy];
   
  /*Send to Geomview*/
    [qv printForGVwithName:name Size:30 Color:20 :red :230];        
    fflush(stdout);

  /*Increment Counter*/
    counter++;

  /*Register Tcl Command and display button*/
    Tcl_CreateCommand(interp, name, qvectCmd,
               (ClientData)qv,(Tcl_CmdDeleteProc *)NULL);
    code = Tcl_Eval(interp,script);
    return code;
}

int undoPoint(char *name, Tcl_Interp *interp) {
    char script[40];  
    int code;

  /*Remove point from group table*/
    [points removeQforKey:name];
   
  /*Remove from  Geomview*/
    fprintf(stdout,"(delete %s)",name);
    fflush(stdout);

  /*Deregister Tcl Command and remove button*/
    Tcl_DeleteCommand(interp, name);
    sprintf(script,"destroy .l%s\n", name);
    sprintf(script,"%s destroy .r%s\n",script, name);
    code = Tcl_Eval(interp,script);
    return code;
}

int Tcl_AppInit(Tcl_Interp *interp) {
    Qvect *one;

    if (Tcl_Init(interp) == TCL_ERROR)
        return TCL_ERROR;
    if (Tk_Init(interp) == TCL_ERROR)
        return TCL_ERROR;

    initEuclGv(interp);
    tetraInEuclGv();
    points  = [[Group alloc] initIn:interp Name:"points"];
    one = [[Qvect alloc] initWithR:1 I:0 J:0 K:0];
   [one printForGVwithName:"ptr" Size:40 Color:230 :20 :20];
   [points insertQ:one Key:"one"];
    counter = 1; /*initialize point count*/   
    
    /*register interest in pick commands*/
    printf("(interest (pick world * nil nil nil nil nil nil nil nil))\n");

/*   Tk_CreateFileHandler(fileno(stdin), TK_READABLE, gvEventProc,
                      (  ClientData) NULL); */

    Tcl_CreateCommand(interp, "transform", transformCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "pick", pickCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);
    Tcl_CreateCommand(interp, "(pick", pickCmd, (ClientData) NULL,
                      (Tcl_CmdDeleteProc *) NULL);

    tcl_RcFileName = "/u/rfrankel/newSU2/expsrc/points.tcl";

    return TCL_OK;
}

int main(int argc, char **argv)
{
    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;
}

void initEuclGv() {
   static Tcl_Interp *interp;     
   int argc,code,*pidPtr,inPipe,outPipe;
   char **argv; 

  fflush(togv);
  code = Tcl_SplitList(interp,"geomview -c - -nopanels -wpos 180,180@200,200 >&2",&argc,&argv);
  Tcl_CreatePipeline(interp,argc,argv,&pidPtr,&inPipe,&outPipe,(int)NULL);
  toNewGv = fdopen(inPipe,"w");
  fromNewGv = fdopen(outPipe,"r");
  fprintf(toNewGv,"(backcolor focus .54 .443 .575)\n");
  fprintf(toNewGv,"(merge camera \"Camera\" {perspective 0})\n");
  fflush(toNewGv); fflush(togv);  
}

void tetraInEuclGv() {

  fprintf(toNewGv,"(read geometry {define tetra"); 
  fprintf(toNewGv," < /u/rfrankel/newSU2/tetra.off})\n");
  fprintf(toNewGv,"(geometry tetra {:tetra})");
  fprintf(toNewGv,"(read geometry {define ABCD"); 
  fprintf(toNewGv," < /u/rfrankel/newSU2/ABCD.vect})\n");
  fprintf(toNewGv,"(geometry ABCD {:ABCD})");
  fprintf(toNewGv,"(scale ABCD 2)");
  fprintf(toNewGv,"(merge-ap ABCD {linewidth 5})");
  fflush(toNewGv);
 } 

static void gvEventProc(clientData, mask)
    ClientData clientData;              /* Not used. */
    int mask;                           /* Not used. */
{

    #define BUFFER_SIZE 4000
    char input[BUFFER_SIZE+1];
    static int gotPartial = 0;
    char *cmd,*pos;
    int code, count;

    count = read(fileno(togv), input, BUFFER_SIZE);
    if (count <= 0) {
        if (!gotPartial) {
                fprintf(stderr,"Error in GV filehandler");
                Tk_DeleteFileHandler(0);
            }
            return;
        } else {
            count = 0;
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

    /* Commands recieved from Geomview may have "(" or ")"
     * we want to convert these to "{" and "}" so they won't
     * confuse Tcl_Eval. (isn't it a cute idea to convert
     * Geomview commands to Tcl commands? Due to Stuart Levy.)
     */

     pos = cmd;
     while(*pos != '\0') {
       if (*pos == '(') *pos = '{';
       if (*pos == ')') *pos = '}';
       pos++;
     }

    /*
     * Disable the stdin file handler while evaluating the  command;
     * otherwise if the command re-enters the event loop we might
     * process commands from stdin before the current command is
     * finished.  Among other things, this will trash the text of the
     * command being evaluated.
     */

    Tk_CreateFileHandler(0, 0, gvEventProc, (ClientData) 0);
    code = Tcl_Eval(interp, cmd);
    Tk_CreateFileHandler(0, TK_READABLE, gvEventProc, (ClientData) 0);
    Tcl_DStringFree(&command);
    
    if (*interp->result != 0) {
        if (code != TCL_OK) {
            printf("%s\n", interp->result);
        }
    }
}






































