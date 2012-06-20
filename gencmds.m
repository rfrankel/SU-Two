#import "gencmds.h"
#import <stdlib.h>
#import "axang.h"
extern Group *points;
static int doPointFlag;

void printCycOff(int n,float z,char *name) {
    int d;
    float x,y,theta;
    char temp[200];

    sprintf(temp, "(read geometry { define %s.off \n",name); 
    Tcl_Write(toNewGv, temp, -1);
    Tcl_Write(toNewGv, "OFF\n", -1);
   // Nvertices, Nfaces, Nedges 
    sprintf(temp,"%d %d %d\n",n,1,n);
    Tcl_Write(toNewGv, temp, -1);

   // vertix coordinates 
    for (d=0;d<n;d++) {
       theta = (float)d*2*3.14156/n;
       x = cos(theta); y = sin(theta);
       sprintf(temp,"%f %f %f\n",x,y,z);
       Tcl_Write(toNewGv, temp, -1);
    }
    
   // face specification 
    sprintf(temp, "%d ",n);
    Tcl_Write(toNewGv, temp, -1);
    for (d=0;d<n;d++) {
      sprintf(temp,"%d ",d); 
      Tcl_Write(toNewGv, temp, -1);
    }
    Tcl_Write(toNewGv,"\n", -1);
    Tcl_Write(toNewGv,"})", -1);
    sprintf(temp, "(geometry %s.off {:%s.off})\n",name,name);
    Tcl_Write(toNewGv, temp, -1);
    Tcl_Flush(toNewGv);
}

int initGrpCmd(ClientData clientData, Tcl_Interp *interp, 
        int argc, char **argv) {
    char filename[20],name[15],name2[15],*grpinds,temp[300];    
    AaGrp *aagrp;
    Qvect *one;
    extern Group *points;
    int code,doPointFlag,n;
 
    char *offap = "appearance {* face material {\
       *ambient 0.486330 0.191709 1.000000\
       *diffuse 0.486330 0.191709 1.000000}})";

    char *offap2 = "appearance {* face material {\
       *ambient 0.586330 0.191709 1.000000\
       *diffuse 0.586330 0.191709 1.000000}})";

    if (argc < 2) {
       interp->result = "wrong # args: should have at least 'initGrp <type>'";
         return TCL_ERROR;
    }
   
    doPointFlag = GROUP_DEMO;

     strcpy(name,"no-name"); 
  /* Initialize objects for 'flat' symettry groups */
    if (strcmp(argv[1],"cyclic") == 0 ||
                strcmp(argv[1],"dihedral") == 0) {  
       if (argc != 3) {
          interp->result = "wrong # of args: should be initGrp cyclic <order>";
          return TCL_ERROR; 
       }
       n = atoi(argv[2]);

    /* Make axis-angle group and object for Euclidean Geomview */
        if (strcmp(argv[1],"cyclic") == 0) {
           aagrp = [[AaGrp alloc] initToCyclicOfOrder:n];
           grpinds = (char *)malloc(12*sizeof(char));    
           sprintf(grpinds,"{1 1 %d}",n);
           Tcl_SetVar(interp,"group_indices",grpinds,TCL_GLOBAL_ONLY);
           sprintf(name,"cyclic%d",n); /*official name of group*/
           printCycOff(n,0,name);
	   sprintf(temp,"(merge-ap %s.off %s",name,offap);
	   Tcl_Write(toNewGv, temp, -1);
        } else {
           aagrp = [[AaGrp alloc] initToDihedralOfOrder:n];
           grpinds = (char *)malloc(12*sizeof(char));    
           sprintf(grpinds,"{2 2 %d}",n);
           Tcl_SetVar(interp,"group_indices",grpinds,TCL_GLOBAL_ONLY);
           sprintf(name,"dihedral%d",n); /*official name of group*/
	   Tcl_Write(toNewGv,"(progn ",-1); 
           printCycOff(n,.01,name);
	   sprintf(temp,"(merge-ap %s.off %s",name,offap); 
	   Tcl_Write(toNewGv,"(progn",-1);
           sprintf(name2,"%s2",name);
           printCycOff(n,-.01,name2);
           sprintf(temp,"(merge-ap %s.off %s)",name2,offap2);  
	   Tcl_Write(toNewGv, temp, -1);
        }
    }

  /* Initialize objects for three-d symettry groups */
  if (strcmp(argv[1],"tetra") == 0 || strcmp(argv[1],"octa") == 0 ||
            strcmp(argv[1],"cube") == 0 || strcmp(argv[1],"icosa") == 0 ||
            strcmp(argv[1],"dodec") == 0) {

    /* Make axis-angle group and object for Euclidean Geomview */
        aagrp = [[AaGrp alloc] init];
        sprintf(filename,"off/%s.off",argv[1]);
        grpinds = [aagrp makeAaGrpFromOff:filename];
        Tcl_SetVar(interp,"group_indices",grpinds,TCL_GLOBAL_ONLY);
	Tcl_Write(toNewGv,"(progn",-1);
        sprintf(temp,"(load %s geometry)",filename);     
        Tcl_Write(toNewGv,temp,-1);
        sprintf(temp,"(merge-ap %s.off %s",argv[1],offap); 
        Tcl_Write(toNewGv,temp,-1);
        strcpy(name,argv[1]); /*official name of group*/
    }
   
  /* Finish group initialization for all symettry groups */
  if (strcmp(name,"no-name") != 0) { 
       
    /* Initialize Euclidean Geomview */
        Tcl_Write(toNewGv,"(bbox-draw World no)",-1);
        Tcl_Write(toNewGv,"(normalization World none)",-1);
        Tcl_Write(toNewGv,"(merge-ap World appearance {linewidth 5})",-1);
        sprintf(temp,"(look %s.off)",name);
	Tcl_Write(toNewGv,temp,-1);

    /* Print axis-angle group to Euclidean Geomview */
        [aagrp printForEuclGV:toNewGv];
        Tcl_Write(toNewGv,")", -1); 
        //endprogn
        Tcl_Flush(toNewGv);

    /* Initialize quaternion group, free aagrp, and inform TCL */
        Tcl_SetVar(interp,"grouptype",name,TCL_GLOBAL_ONLY);
        points  = [[Group alloc] initIn:interp Name:name];
        [aagrp convertAaGrpTo:points];
        [aagrp free];
        code = Tcl_EvalFile(interp,"group.tcl");
        return code;

   } else if (strcmp(argv[1],"random") == 0) {
      
    /* Create and print initial point */
        one = [[Qvect alloc] initWithR:1 I:0 J:0 K:0];
        Tcl_SetVar(interp,"grouptype",argv[1],TCL_GLOBAL_ONLY);
        points  = [[Group alloc] initIn:interp Name:argv[1]];        
        [points insertQ:one Key:"ptr"];
        [one printForGVwithName:"ptr" Size:40 Col:".9 .08 .08"];
        
    /* Print a single aa vect to Euclidean Geomview */
        Tcl_Write(toNewGv,"(bbox-draw World no)",-1);
        Tcl_Write(toNewGv,"(normalization World none)",-1);
        Tcl_Write(toNewGv,"(merge-ap World appearance {linewidth 5})",-1);
        Tcl_Write(toNewGv, "(read geometry { define ptr \n",-1);  
        Tcl_Write(toNewGv, "VECT \n",-1);
        Tcl_Write(toNewGv, "1 3 0 \n",-1); /*1 line, 3 verts, 0 colors*/
        Tcl_Write(toNewGv, "3 0 \n",-1);  /*3 verts in line, 0 colors*/
        Tcl_Write(toNewGv, "0 0 0 \n",-1); /*First point coords*/
        Tcl_Write(toNewGv, "0 0 1 \n",-1); /*second point coords*/
        Tcl_Write(toNewGv, ".14285 -.14285 1 \n",-1); /*third point coords*/
        Tcl_Write(toNewGv, "})\n",-1);
        Tcl_Write(toNewGv, "(geometry ptr {:ptr})\n",-1); 
        Tcl_Write(toNewGv,"(merge-ap ptr appearance { material {",-1);
        Tcl_Write(toNewGv," *edgecolor .9 .08 .08}})",-1);
        Tcl_Flush(toNewGv);          

    } else {
        Tcl_AppendResult(interp,"bad initGrp command \"", argv[1],
            "\": should be tetra, octa, cube, dodec, icosa,
                         cyclic, dihedral, or random", (char *)NULL);
        return TCL_ERROR;
    }    
    return TCL_OK;
}

int groupCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    Group *group;
    Qvect *qv1,*qv2, *prod;
    char *colkey,*col,*prodkey;
    int matched,sgrpargc,s,t;
    float r,i,j,k;
    char **sgrpargv;

    group = (id) clientData;
    if (argc < 2) {
         interp->result = "too few args";
         return TCL_ERROR;
    }

    if (strcmp(argv[1],"name") == 0) {
       sprintf(interp->result,"%s",argv[0]);
    } else if (strcmp(argv[1],"list") == 0) {
       [group listGrp];
    } else if (strcmp(argv[1],"add") == 0) {
        if (argc != 5) {
           interp->result = "wrong # of args:
                      should be <group> add <q-value> <name> <color-name>";
           return TCL_ERROR;
        }
        matched = sscanf(argv[2]," %f %f %f %f ",&r,&i,&j,&k);   
           if (matched == 4) {
              qv1 = [[Qvect alloc] initWithR:r I:i J:j K:k];
           } else {
              fprintf(stderr,"quaternion value didn't parse properly");
              return TCL_OK;
           }
          /*Add point to group table*/          
           [group insertQ:qv1 Key:argv[3]];

          /*Print for Geomview */
           colkey = Tcl_GetVar2(interp,"color",argv[4],TCL_GLOBAL_ONLY);
           if (colkey == NULL) {
               interp->result = "not a valid color key";
               return TCL_ERROR;
           }
           col = [basicDecor findFaceRGBforKey:colkey];
           [qv1 printForGVwithName:argv[3] Size:30 Col:col];        
           fflush(togv);

          /* Register Tcl command */
           Tcl_CreateCommand(interp, argv[3], qvectCmd,
                     (ClientData)qv1,(Tcl_CmdDeleteProc *)NULL);
    } else if (strcmp(argv[1],"delete") == 0) {
         if (argc != 3) {
             interp->result = "wrong # of args: should be <group> delete <pt>";
             return TCL_ERROR;
         }

        /*Remove point from group table*/
           [group removeQforKey:argv[2]];

        /*Remove from  Geomview*/
            fprintf(stdout,"(delete %s)",argv[2]);
            fflush(stdout);

        /*Deregister Tcl Command*/
            Tcl_DeleteCommand(interp, argv[2]);
    } else if (strcmp(argv[1],"kill") == 0) { 
            [group free];
	    Tcl_Write(toNewGv,"(delete World)",-1); 
            Tcl_Flush(toNewGv);
            Tcl_DeleteCommand(interp,argv[0]);     
    } else if (strcmp(argv[1],"multiply") == 0 ||
                   strcmp(argv[1],"conjugate")== 0) {
         if (argc != 5) {
             interp->result = "wrong # of args:
                  should be <group> <operation> <pt1> to/by <pt2>";
             return TCL_ERROR;
         }
       qv1 = [group findQforKey:argv[2]];
       qv2 = [group findQforKey:argv[4]];
       if (strcmp(argv[1],"multiply") == 0) prod = [qv1 prodWith: qv2];
       if (strcmp(argv[1],"conjugate") == 0) prod = [qv1 conjBy: qv2];
       prodkey = [points matchPoint: prod];
       sprintf(interp->result,"%s",prodkey);
    } else if (strcmp(argv[1],"Smultiply") == 0 ||
                   strcmp(argv[1],"Sconjugate")== 0) {
         if (argc != 5) {
             interp->result = "wrong # of args:
                 should be <group> <operation> <subgroup-list> to/by <pt>";
             return TCL_ERROR;
         }
       Tcl_SplitList(interp,argv[2],&sgrpargc,&sgrpargv);  
       for (s=0;s<sgrpargc;s++) {
           qv1 = [group findQforKey:sgrpargv[s]];
           qv2 = [group findQforKey:argv[4]];
           if (strcmp(argv[1],"Smultiply") == 0) prod = [qv1 prodWith: qv2];
           if (strcmp(argv[1],"Sconjugate") == 0) prod = [qv1 conjBy: qv2];
           prodkey = [points matchPoint: prod];
           Tcl_AppendElement(interp,prodkey);                     
       }
    } else if (strcmp(argv[1],"multiplyS") == 0 ||
                   strcmp(argv[1],"conjugateS")== 0) {
         if (argc != 5) {
             interp->result = "wrong # of args:
                 should be <group> <operation> <pt> to/by <subgroup-list>";
             return TCL_ERROR;
         }
       Tcl_SplitList(interp,argv[4],&sgrpargc,&sgrpargv);  
       for (s=0;s<sgrpargc;s++) {
           qv1 = [group findQforKey:argv[2]];
           qv2 = [group findQforKey:sgrpargv[s]];
           if (strcmp(argv[1],"multiplyS") == 0) prod = [qv1 prodWith: qv2];
           if (strcmp(argv[1],"conjugateS") == 0) prod = [qv1 conjBy: qv2];
           prodkey = [group matchPoint: prod];
           Tcl_AppendElement(interp,prodkey);                     
           prod = [prod free];
       }
    } else if (strcmp(argv[1],"Scomplete") == 0) {
         if (argc != 3) {
             interp->result = "wrong # of args:
                 should be <group> Scomplete <subgroup-list>";
             return TCL_ERROR;
         }
       Tcl_SplitList(interp,argv[2],&sgrpargc,&sgrpargv);  
       for(t=0;t<sgrpargc;t++) {
           for (s=0;s<sgrpargc;s++) {
               qv1 = [group findQforKey:sgrpargv[t]];
               qv2 = [group findQforKey:sgrpargv[s]];
               prod = [qv1 prodWith: qv2];
               prodkey = [group matchPoint: prod];
   /* If our product is neither in the original group nor in the list of 
      new points we are building in the result, add it to the result */
           if (strstr(argv[2],prodkey) == NULL &&
                     strstr(interp->result,prodkey) == NULL)
               Tcl_AppendElement(interp,prodkey);
          }   
       }
    } else if (strcmp(argv[1],"Sgvname") == 0) {
         if (argc != 4) {
             interp->result = "wrong # of args:
                 should be <group> Sgvname <subgroup-list> <name>";
             return TCL_ERROR;
         }
       Tcl_SplitList(interp,argv[2],&sgrpargc,&sgrpargv);  
       fprintf(togv,"{ LIST %s",argv[3]);
       for (s=0;s<sgrpargc;s++) {
              fprintf(togv," %s ",sgrpargv[s]);
       } 
       fprintf(togv,"}");
       fflush(togv);
    } else if (strcmp(argv[1],"print") == 0) {
         if (argc != 3) {
             interp->result = "wrong # of args:
                 should be <group> print <size>";
             return TCL_ERROR;
         }
       printForGV(interp,argv[0],group,(atoi(argv[2])));
    } else {
       Tcl_AppendResult(interp, "bad group command \"",
             argv[1],"\": should be name, add, delete, kill, Sgvname, multiply,
          conjugate, [S]multiply[S], [S]conjugate[S], print, or list", (char *)NULL);
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
             argv[1],"\": should be name, list or valR/I/J/K", (char *)NULL);
       return TCL_ERROR;
    }
    return TCL_OK;
}

int listGrpCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    extern Group *points;
     
    if (argc != 1) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }

    [points listGrp];
    return TCL_OK;
}  

int killGrpCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    [points free];
    Tcl_Write(toNewGv,"(delete World)",-1); 
    Tcl_Flush(toNewGv);
    return TCL_OK;
}

int removeFromGvCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
 
    if (argc != 2) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }

    fprintf(stdout,"(delete %s)",argv[1]);
    fflush(stdout);
    return TCL_OK;
}

int faceOffCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {

    if (argc != 2) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }
  
    fprintf(stdout,"(merge-ap %s appearance {*-face})",argv[1]);
    fflush(stdout);
    return TCL_OK;
}

int prognCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {

    fprintf(stdout,"(progn");
    return TCL_OK;
}

int endprognCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    fprintf(stdout,")");  
    fflush(stdout);
    return TCL_OK;
}    

    
int doPoint(Qvect *qv, Tcl_Interp *interp) {
    char name[10],script[250],*namecopy,*key,col[20];    
    int red,code,counter;

  if (doPointFlag == MULTIPLY_DEMO) {
    counter = 0; /*cluge*/
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
    sprintf(col,".2 %f .8",(float)red/256.);
    [qv printForGVwithName:name Size:30 Col:col];        
    fflush(stdout);

  /*Increment Counter*/
   counter++;

  /*Register Tcl Command and display button*/
    Tcl_CreateCommand(interp, name, qvectCmd,
               (ClientData)qv,(Tcl_CmdDeleteProc *)NULL);
    code = Tcl_Eval(interp,script);
    return code;
   }
 
  if (doPointFlag == GROUP_DEMO) {
    key = [points nearestPoint:qv];
    fprintf(togv,"(merge-ap %s appearance { *+face material {",key);
    fprintf(togv,"*ambient 0.0784 0.0784 0.9019");
    fprintf(togv," *diffuse 0.0784 0.0784 0.9019}})");
    fflush(togv);
    sprintf(script,".g.%s select",key);
    code = Tcl_Eval(interp,script);
    sprintf(interp->result,"%s",key);
   }
  return TCL_OK;
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

int markPointCmd(ClientData clientData, Tcl_Interp *interp,
                     int argc, char **argv) {
   
    if (argc != 2) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }

  fprintf(togv,"(if (real-id %s)",argv[1]);
  fprintf(togv,"(merge-ap %s appearance { *+face material {",argv[1]);
  fprintf(togv,"*ambient 0.560 0.000 0.970");
  fprintf(togv," *diffuse 0.560 0.000 0.970}}))");
  fflush(togv);
  return TCL_OK;
}

int unMarkPointCmd(ClientData clientData, Tcl_Interp *interp,
                         int argc, char **argv) {
    char temp[300];  
 
    if (argc != 2) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }

    sprintf(temp,"(merge-ap %s appearance { material {",argv[1]);
       Tcl_Write(toNewGv,temp,-1);
    Tcl_Write(toNewGv," *edgecolor  0 0 0}})",-1);
    Tcl_Flush(toNewGv); 

  fprintf(togv,"(merge-ap %s appearance { *+face material {",argv[1]);
  fprintf(togv,"*ambient 0.0784 0.0784 0.9019");
  fprintf(togv," *diffuse 0.0784 0.0784 0.9019}})");
  fflush(togv);
  return TCL_OK;
}

int turnAndMarkCmd(ClientData clientData, Tcl_Interp *interp,
                     int argc, char **argv) {
  extern Tcl_Channel toNewGv;
  Qvect *qv;
  char temp[200];

  if (argc != 2) {
         interp->result = "wrong # args";
         return TCL_ERROR;
    }

  if (strlen(argv[1]) > 5) {
         interp->result = "key too long";
         return TCL_ERROR;
    }

  fflush(togv); //fflush(toNewGv);
  qv = [points findQforKey:argv[1]];  
  sprintf(temp,"(if (real-id %s)",argv[1]);
    Tcl_Write(toNewGv, temp, -1);
  sprintf(temp,"(merge-ap %s appearance { material {",argv[1]);
    Tcl_Write(toNewGv, temp, -1);
  Tcl_Write(toNewGv," *edgecolor  0 .938 .83}}))",-1); 
  if (strstr(argv[1],"one") == NULL) {
     [qv doIncrTransinSteps:36 to:toNewGv];
  } else {
     Tcl_Write(toNewGv,"(xform-set world 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1)",-1);
  }
  Tcl_Flush(toNewGv);

//  fprintf(togv,"(if (real-id %s)",argv[1]);
//  fprintf(togv,"(merge-ap %s appearance {* face material {",argv[1]);
//  fprintf(togv,"ambient .948 0.346 1");
//  fprintf(togv," *diffuse 0.948 0.346 1}}))");
//  fflush(togv);
  return TCL_OK;
}

int printForGV(Tcl_Interp *interp, char *grptype,
                             Group *group, int size) { 
    Tcl_HashEntry *entryPtr;
    Tcl_HashSearch search;
    Tcl_HashTable Table;
    char *key; 
    float ang,r,i,j,k,red,green,blue,p,scalefact,theta,x,y;
    Qvect *vert,*prod,*qv;
    AxAng *aa[32];
    int code,h,n,m;    
    char *grpcol,script[20];

    ang = (3.14159)/size;
    Table = [group getTable];
       sprintf(script,"basicDecor value group");
       code = Tcl_Eval(interp,script); 
       grpcol = interp->result;
       sscanf(grpcol," %f %f %f ",&red,&green,&blue);
    if (size == 0) {
       [group printForGVasPointswithCol:grpcol];
    } else if (strcmp(grptype,"tetra") == 0) {
       [group printForGVwithSize:size Col:grpcol];

    } else if (strstr(grptype,"cyclic") != NULL) {
   /* initialize order of group, number of faces in lens, size factor */
       sscanf(grptype,"cyclic%d",&n);
       if (n>5) m = n;     /* make sure the lens has enough edges */
       else if (n==1) m = 5;  /* not to look horribly polygonal */
       else if (n==2) m = 8;
       else m = 2*n;
       scalefact = (float)size/6.;

   /* The top and bottom axis of lens */
       ang = scalefact*3.14159/n; 
       aa[0] = [[AxAng alloc] initWithAxisX: 0 Y: 0 Z: 1  Ang:ang];
       aa[1] = [[AxAng alloc] initWithAxisX: 0 Y: 0 Z:-1  Ang:ang];

   /* The edges of the lens (either 5 or n-fold symettry, depending on n) */
       ang = scalefact*3.14159;
       for (h=2;h<m+2;h++) {
          theta = (float)(h-2)*2*3.14159/m;
          x = cos(theta); y = sin(theta);
          aa[h] = [[AxAng alloc] initWithAxisX: x Y: y Z:0  Ang:ang];
       }

  /* print out vertices to geomview */
       entryPtr = Tcl_FirstHashEntry(&Table,&search);
       while(entryPtr != NULL) {
          key = Tcl_GetHashKey(&Table,entryPtr);
          qv = Tcl_GetHashValue(entryPtr);
          fprintf(togv, "(read geometry { define %s \n",key);  
          fprintf(togv,"4OFF\n");
          fprintf(togv,"%d %d %d\n",m+2,2*m,3*m); /*verts,faces,edges*/
          for (h=0;h<(m+2);h++) {
             vert = [aa[h] convertToQ];
             prod = [vert prodWith:qv];
             r = [prod valReal];
             i = [prod valI];
             j = [prod valJ];
             k = [prod valK];
             fprintf(togv, "%f %f %f %f\n",k,j,i,r);
             [prod free]; [vert free];
          }
          for (h=2;h<(m+1);h++) {
           /* top section */
             fprintf(togv, "3 0 %d %d %f %f %f\n",h,h+1,red,green,blue);            
           /* bottom section */
             fprintf(togv, "3 1 %d %d %f %f %f\n",h,h+1,red,green,blue);            
          }
          /* last two sections (cluge) connecting end to beginning of circle */
          fprintf(togv, "3 0 %d 2 %f %f %f\n",m+1,red,green,blue);            
          fprintf(togv, "3 1 %d 2 %f %f %f\n",m+1,red,green,blue);            
          fprintf(togv, "}\n");
          fprintf(togv, ")\n");
          fprintf(togv, "(geometry %s {:%s})\n",key,key);
          Tcl_SetVar2(interp,"color",key,"group",TCL_GLOBAL_ONLY);
          fflush(togv);
          entryPtr = Tcl_NextHashEntry(&search);
          }
       }
    else if (strstr(grptype,"dihedral") != NULL) {
       sscanf(grptype,"dihedral%d",&n);
       n = 2*n; /* cludge -- rather than double n everywhere below */
       scalefact = (float)size/3.;       
       ang = 3.14159 / (float)n;
       for (h=0;h<2*n;h=h+2) {
           theta = (float)(h+1)*3.14159/n;
           x = (3.14156/4)*cos(theta); y = (3.14159/4)*sin(theta);
           aa[h] =  [[AxAng alloc] initWithAxisX:x Y:y Z: ang  Ang:(scalefact*ang)];
           aa[h+1] =  [[AxAng alloc] initWithAxisX:x Y:y Z: -ang  Ang:(scalefact*ang)];
       }
  /* print out vertices to geomview */
       entryPtr = Tcl_FirstHashEntry(&Table,&search);
       while(entryPtr != NULL) {
          key = Tcl_GetHashKey(&Table,entryPtr);
          qv = Tcl_GetHashValue(entryPtr);
          fprintf(togv, "(read geometry { define %s \n",key);  
          fprintf(togv,"4OFF\n");
          fprintf(togv,"%d %d %d\n",2*n,n+2,3*n); /*verts,faces,edges*/
          for (h=0;h<2*n;h++) {
             vert = [aa[h] convertToQ];
             prod = [vert prodWith:qv];
             r = [prod valReal];
             i = [prod valI];
             j = [prod valJ];
             k = [prod valK];
             fprintf(togv, "%f %f %f %f\n",k,j,i,r);
             [prod free]; [vert free];
          }
   /* print out square edges of prism */
          for (h=0;h<2*n-2;h=h+2) {
             fprintf(togv, "4 %d %d %d %d %f %f %f\n",h,h+1,h+3,h+2,red,green,blue);   
          }
          /* last section (cluge) connecting end to beginning of circle */
          fprintf(togv, "4 %d %d 1 0 %f %f %f\n",2*n-2,2*n-1,red,green,blue);
   /* print out top and bottom -- top first*/
          fprintf(togv, "%d ",n);
          for (h=0;h<n;h++) {
             fprintf(togv,"%d ",2*h); 
          }
          fprintf(togv,"%f %f %f \n",red,green,blue);            
      /* now bottom */
          fprintf(togv, "%d ",n);
          for (h=0;h<n;h++) {
             fprintf(togv,"%d ",2*h+1); 
          }
          fprintf(togv,"%f %f %f \n",red,green,blue);            
      /* finish up object */
          fprintf(togv, "}\n");
          fprintf(togv, ")\n");
          fprintf(togv, "(geometry %s {:%s})\n",key,key);
          Tcl_SetVar2(interp,"color",key,"group",TCL_GLOBAL_ONLY);
          fflush(togv);
          entryPtr = Tcl_NextHashEntry(&search);
          }
       }
   else if (strcmp(grptype,"cube") == 0 || strcmp(grptype,"octa") == 0) {
       p = .414214;
       aa[0] = [[AxAng alloc] initWithAxisX: 1 Y: p Z: 1  Ang:ang];
       aa[1] = [[AxAng alloc] initWithAxisX: p Y: 1 Z: 1  Ang:ang];
       aa[2] = [[AxAng alloc] initWithAxisX:-p Y: 1 Z: 1  Ang:ang];
       aa[3] = [[AxAng alloc] initWithAxisX:-1 Y: p Z: 1  Ang:ang];
       aa[4] = [[AxAng alloc] initWithAxisX:-1 Y:-p Z: 1  Ang:ang];
       aa[5] = [[AxAng alloc] initWithAxisX:-p Y:-1 Z: 1  Ang:ang];
       aa[6] = [[AxAng alloc] initWithAxisX: p Y:-1 Z: 1  Ang:ang];
       aa[7] = [[AxAng alloc] initWithAxisX: 1 Y:-p Z: 1  Ang:ang];
       aa[8] = [[AxAng alloc] initWithAxisX: 1 Y: 1 Z: p  Ang:ang];
       aa[9] = [[AxAng alloc] initWithAxisX:-1 Y: 1 Z: p  Ang:ang];
       aa[10] =[[AxAng alloc] initWithAxisX:-1 Y:-1 Z: p  Ang:ang];
       aa[11] =[[AxAng alloc] initWithAxisX: 1 Y:-1 Z: p  Ang:ang];
       aa[12] =[[AxAng alloc] initWithAxisX: 1 Y: 1 Z:-p  Ang:ang];
       aa[13] =[[AxAng alloc] initWithAxisX:-1 Y: 1 Z:-p  Ang:ang];
       aa[14] =[[AxAng alloc] initWithAxisX:-1 Y:-1 Z:-p  Ang:ang];
       aa[15] =[[AxAng alloc] initWithAxisX: 1 Y:-1 Z:-p  Ang:ang];
       aa[16] =[[AxAng alloc] initWithAxisX: 1 Y: p Z:-1  Ang:ang];
       aa[17] =[[AxAng alloc] initWithAxisX: p Y: 1 Z:-1  Ang:ang];
       aa[18] =[[AxAng alloc] initWithAxisX:-p Y: 1 Z:-1  Ang:ang];
       aa[19] =[[AxAng alloc] initWithAxisX:-1 Y: p Z:-1  Ang:ang];
       aa[20] =[[AxAng alloc] initWithAxisX:-1 Y:-p Z:-1  Ang:ang];
       aa[21] =[[AxAng alloc] initWithAxisX:-p Y:-1 Z:-1  Ang:ang];
       aa[22] =[[AxAng alloc] initWithAxisX: p Y:-1 Z:-1  Ang:ang];
       aa[23] =[[AxAng alloc] initWithAxisX: 1 Y:-p Z:-1  Ang:ang];

    entryPtr = Tcl_FirstHashEntry(&Table,&search);
    while(entryPtr != NULL) {
      key = Tcl_GetHashKey(&Table,entryPtr);
      qv = Tcl_GetHashValue(entryPtr);
      fprintf(togv, "(read geometry { define %s \n",key);  
      fprintf(togv,"4OFF\n");
      fprintf(togv,"24 14 36\n");
      for (h=0;h<24;h++) {
        vert = [aa[h] convertToQ];
        prod = [vert prodWith:qv];
        r = [prod valReal];
        i = [prod valI];
        j = [prod valJ];
        k = [prod valK];
        fprintf(togv, "%f %f %f %f\n",k,j,i,r);
        [prod free]; [vert free];
      }
    fprintf(togv,"8 0 1 2 3 4 5 6 7 %f %f %f\n",red,green,blue);
    fprintf(togv,"8 0 8 12 16 23 15 11 7 %f %f %f\n",red,green,blue);
    fprintf(togv,"8 1 2 9 13 18 17 12 8 %f %f %f\n",red,green,blue);
    fprintf(togv,"8 3 4 10 14 20 19 13 9 %f %f %f\n",red,green,blue);
    fprintf(togv,"8 5 6 11 15 22 21 14 10 %f %f %f\n",red,green,blue);
    fprintf(togv,"8 16 17 18 19 20 21 22 23 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 0 1 8 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 2 3 9 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 4 5 10 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 6 7 11 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 12 16 17 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 13 18 19 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 14 20 21 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 15 22 23 %f %f %f\n",red,green,blue);
     fprintf(togv, "}\n");
     fprintf(togv, ")\n");
     fprintf(togv, "(geometry %s {:%s})\n",key,key);
     Tcl_SetVar2(interp,"color",key,"group",TCL_GLOBAL_ONLY);
     fflush(togv);
    entryPtr = Tcl_NextHashEntry(&search);
    }
   } else if (strcmp(grptype,"icosa") == 0 || strcmp(grptype,"dodec") == 0) {
    aa[0] = [[AxAng alloc] initWithAxisX:1.21412 Y:0.      Z:1.5893  Ang:ang];
    aa[1] = [[AxAng alloc] initWithAxisX:.375185 Y:1.1547  Z:1.5893  Ang:ang];
    aa[2] = [[AxAng alloc] initWithAxisX:-.98225 Y:.71364  Z:1.5893  Ang:ang];
    aa[3] = [[AxAng alloc] initWithAxisX:-.98225 Y:-.71364 Z:1.5893  Ang:ang];
    aa[4] = [[AxAng alloc] initWithAxisX:.375185 Y:-1.1547 Z:1.5893  Ang:ang];
    aa[5] = [[AxAng alloc] initWithAxisX:1.9644  Y:0       Z:.3752  Ang:ang];
    aa[6] = [[AxAng alloc] initWithAxisX:.60706  Y:1.8683  Z:.3752  Ang:ang];
    aa[7] = [[AxAng alloc] initWithAxisX:-1.5893 Y:1.1547  Z:.3752  Ang:ang];
    aa[8] = [[AxAng alloc] initWithAxisX:-1.5893 Y:-1.1547 Z:.3752  Ang:ang];
    aa[9] = [[AxAng alloc] initWithAxisX:.60706  Y:-1.8683 Z:.3752  Ang:ang];
    aa[10] = [[AxAng alloc] initWithAxisX:1.5893 Y:1.1547  Z:-.3752 Ang:ang];
    aa[11] = [[AxAng alloc] initWithAxisX:-.6071 Y:1.8683  Z:-.3752 Ang:ang];
    aa[12] = [[AxAng alloc] initWithAxisX:-1.964 Y:0       Z:-.3752 Ang:ang];
    aa[13] = [[AxAng alloc] initWithAxisX:-.6071 Y:-1.8683 Z:-.3752 Ang:ang];
    aa[14] = [[AxAng alloc] initWithAxisX:1.5893 Y:-1.1547 Z:-.3752 Ang:ang];
    aa[15] = [[AxAng alloc] initWithAxisX:.98225 Y:.71364  Z:-1.5893 Ang:ang];
    aa[16] = [[AxAng alloc] initWithAxisX:-.3752 Y:1.1547  Z:-1.5893 Ang:ang];
    aa[17] = [[AxAng alloc] initWithAxisX:-1.214 Y:0.      Z:-1.5893 Ang:ang];
    aa[18] = [[AxAng alloc] initWithAxisX:-.3752 Y:-1.1547 Z:-1.5893 Ang:ang];
    aa[19] = [[AxAng alloc] initWithAxisX:.98225 Y:-.71364 Z:-1.5893 Ang:ang];

    entryPtr = Tcl_FirstHashEntry(&Table,&search);
    while(entryPtr != NULL) {
      key = Tcl_GetHashKey(&Table,entryPtr);
      qv = Tcl_GetHashValue(entryPtr);
      fprintf(togv, "(read geometry { define %s \n",key);  
      fprintf(togv,"4OFF\n");
      fprintf(togv,"20 12 30\n");
      for (h=0;h<20;h++) {
        vert = [aa[h] convertToQ];
        prod = [vert prodWith:qv];
        r = [prod valReal];
        i = [prod valI];
        j = [prod valJ];
        k = [prod valK];
        fprintf(togv, "%f %f %f %f\n",k,j,i,r);
        [prod free]; [vert free]; 
      }
     fprintf(togv, "5 0 1 2 3 4   %f %f %f\n",red,green,blue);
     fprintf(togv, "5 0 5 10 6 1  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 1 6 11 7 2  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 2 7 12 8 3  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 3 8 13 9 4  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 4 9 14 5 0  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 15 10 5 14 19  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 16 11 6 10 15   %f %f %f\n",red,green,blue);
     fprintf(togv, "5 17 12 7 11 16  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 18 13 8 12 17  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 19 14 9 13 18  %f %f %f\n",red,green,blue);
     fprintf(togv, "5 19 18 17 16 15  %f %f %f\n",red,green,blue);
     fprintf(togv, "}\n");
     fprintf(togv, ")\n");
     fprintf(togv, "(geometry %s {:%s})\n",key,key);
     Tcl_SetVar2(interp,"color",key,"group",TCL_GLOBAL_ONLY);
     fflush(togv);
    entryPtr = Tcl_NextHashEntry(&search);
    }
   }
   return TCL_OK;
}






