#import "objcmds.h"
#import <tk.h>
static char *key;           /* the geomview filehandler for the object */
static Qvect *qv1;          /* the first quaternion for a diag-object */
static Tcl_Interp *Interp;  /* the interpreter (for retrieving color values)*/
static char *appkey;        /* the key for the current appearance */

int faceProc(char *appPtr,char *tablekey, char *nextArg)   {
     App *app;          
     char *color, str[20];
     float r,g,b;
     int matched;

     app = *((App **)appPtr);    

   /*Create new app if a specific app for this object doesn't already exist*/ 
     if (strcmp(appkey,key) != 0) {
        app = [app copy];
        [basicDecor insertA:app Key:key];
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY); 
     } 

     fprintf(togv,"(if (real-id %s)",key);   
       if (strcmp(nextArg,"on") == 0) {
            color = [app valFColor];
            /* removed overrides from face, transparent, amb and diff*/
            fprintf(togv,"(merge-ap %s appearance {+face -transparent",key); 
              fprintf(togv," material {ambient %s",color);
              fprintf(togv," diffuse %s}})",color);
              fflush(togv);
              [app setF: 1];  
       }else if (strcmp(nextArg,"off") == 0) {
              fprintf(togv,"(merge-ap %s appearance {*-face})",key);
              [app setF:0];
       }else if (strstr(nextArg,"color") != NULL) {
              matched = sscanf(nextArg,"%s %f %f %f",str,&r,&g,&b);
              if (matched != 4) { 
	          fprintf(stderr,"-face color didn't parse properly");
		  return 1;
	      }      
              fprintf(togv,"(merge-ap %s appearance {+face",key); 
              fprintf(togv," material {ambient %f %f %f",r,g,b);
              fprintf(togv," diffuse %f %f %f}})",r,g,b);
	      /* removed overrides as shown below */
	      /* fprintf(togv,"(merge-ap %s appearance {*+face",key); 
              fprintf(togv," material {*ambient %f %f %f",r,g,b);
              fprintf(togv," *diffuse %f %f %f}})",r,g,b);*/
              fflush(togv);
              [app setF: 1];
	      sprintf(nextArg," %f %f %f ",r,g,b); 
              [app setFColor:nextArg];   
        }else if (strstr(nextArg,"back") != NULL) {
              if ([app valType] != CAM) {
                fprintf(stderr,"decor-set-object-face-background:");
                fprintf(stderr," should be a camera object ");
                if (strstr(key,"Cam") == 0) {
                   Interp->result = "not a camera object";
                   return TCL_ERROR;  
                } else [app setType:CAM];
              }
	      matched = sscanf(nextArg,"%s %f %f %f",str,&r,&g,&b);
              if (matched != 4) {
	          fprintf(stderr,"-face backcolor didn't parse properly");
		  return 1;
	      }  
	      sprintf(nextArg," %f %f %f ",r,g,b);    
              fprintf(togv,"(backcolor %s %s)\n",key,nextArg);
	      [app setF: 1];      
              [app setFColor:nextArg];
         }else {
               Tcl_AppendResult(Interp,"bad -face command \"",
                  nextArg,"\": should be on, off or color", (char *)NULL);
               return TCL_ERROR;
         }
   fprintf(togv,")");
   *((App **)appPtr) = app;
   return 1;   
}

int edgeProc(char *appPtr, char *tablekey, char *nextArg) {
     App *app;
     char *color,str[20];
     int matched,width;
     float r,g,b;
     
     app = *((App **)appPtr);

   /*Create new app if a specific app for this object doesn't already exist*/ 
     if (strcmp(appkey,key) != 0) {
        app = [app copy];
        [basicDecor insertA:app Key:key];
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY); 
     } 

     fprintf(togv,"(if (real-id %s)",key); 
     if (strcmp(nextArg,"on") == 0) {
             color = [app valEColor];
             fprintf(togv,"(merge-ap %s appearance {*+edge ",key);
             fprintf(togv,"material {edgecolor %s}})",color); 
             [app setE:1];                    
        } else if (strcmp(nextArg,"off") == 0) {
               fprintf(togv,"(merge-ap %s appearance {*-edge})",key);
               [app setE:0];
        } else if (strstr(nextArg,"width") != NULL) {
                matched = sscanf(nextArg,"%s %d",str,&width);
              if (matched != 2) {
	          fprintf(stderr,"-edge width didn't parse properly");
		  return 1;
	      }  
	       fprintf(togv,"(merge-ap %s appearance",key);
               fprintf(togv,"{*+edge linewidth %d})",width);
               [app setE:width];               
	} else if (strstr(nextArg,"color") != NULL) {
              matched = sscanf(nextArg,"%s %f %f %f",str,&r,&g,&b);
              if (matched != 4) {
	          fprintf(stderr,"-edge color didn't parse properly");
		  return 1;
	      }  
	      sprintf(nextArg," %f %f %f ",r,g,b);    
              fprintf(togv,"(merge-ap %s appearance {*+edge",key); 
               fprintf(togv," material {edgecolor %s}})",nextArg);
               [app setE: 1];  
               [app setEColor:nextArg];   
        } else {
               Tcl_AppendResult(Interp,"bad decor-set-object-edge command \"",
                  nextArg,"\": should be on,off,width or color", (char *)NULL);
               return TCL_ERROR;
        }
     fprintf(togv,")");
     *((App **)appPtr) = app;
     return 1;   
}

int transProc(char *appPtr, char *tablekey, char *nextArg) {
     float alpha;
     App *app;
 
     app = *((App **)appPtr);
       
  /*Create new app if a specific app for this object doesn't already exist*/ 
     if (strcmp(appkey,key) != 0) {
        app = [app copy];
        [basicDecor insertA:app Key:key];
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY); 
     } 


     alpha = atof(nextArg);
     if (alpha>=1) alpha = .95;
     fprintf(togv,"(if (real-id %s) ",key);
     fprintf(togv,"(merge-ap %s appearance {*+face *+transparent ",key);   
     fprintf(togv,"material {*alpha %f}}))",alpha);
     fflush(togv);
     [app setF:alpha];
     *((App **)appPtr) = app;
      return 1;
}

int appearProc(char *appPtr, char *tablekey, char *nextArg) {
     App *app;

     appkey = nextArg;  /* this is linked to tcl's color var too*/	
     app = [basicDecor findAforKey: appkey];
     if (app != NULL) {
        [app printForGv:key];
     } else fprintf(stderr,"no appearance for key:%s",appkey);
     *((App **)appPtr) = app;
     return 1;
}

int decorCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    Decor *decor;
    App *app;
    char appvar[20],result[30],*facecolor,*edgecolor;
    char *light1,*l1pos,*light2,*l2pos,*light3,*l3pos;
    int code,red,green,blue;
    float r,g,b;

   Tk_ArgvInfo argTable[] = {
     {"-face", TK_ARGV_FUNC, (char *) faceProc, (char *)&app, 
                "Specify face appearance "}, 
     {"-edge", TK_ARGV_FUNC, (char *) edgeProc, (char *)&app, 
                "Specify edge appearance "}, 		   	   
     {"-transparent", TK_ARGV_FUNC, (char *) transProc, (char *)&app, 
                "Turn on transparancy"},
     {"-appearance", TK_ARGV_FUNC, (char *)appearProc, (char *)&app,
                "Specify an appearance by name"}, 		
     {(char *) NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,(char *) NULL}};

    decor = (Decor *) clientData;
    Interp = interp;
    if (argc < 3) {
         interp->result = "too few args";
         return TCL_ERROR;
    }

    if (strcmp(argv[1],"value") == 0) {
       sprintf(interp->result,"%s",[decor findFaceRGBforKey:argv[2]]);
    } else if (strcmp(argv[1],"list") == 0) {
       [basicDecor listKeys];
    } else if (strcmp(argv[1],"tclval") == 0) {
       if (argc < 4) {
          interp->result = "too few args: should be
                 <decor> tclval <key> face|facecolor|edge|edgecolor";
          return TCL_ERROR;
       }
       key = argv[2];
       code = Tcl_VarEval(interp,"newcolor ",key," default",(char *)NULL);
       appkey = (char *)malloc(strlen(interp->result)+1);
       strcpy(appkey,interp->result);  
       app = [decor initEntry:appkey];    
       if (strcmp(argv[3],"face") == 0) {
          sprintf(result,"%f",[app valF]);
          strcpy(interp->result,result);
       } else if (strcmp(argv[3],"facecolor") == 0) {
          sscanf([app valFColor]," %f %f %f ",&r,&g,&b);
        sprintf(result,"#%02x%02x%02x",(int)(256*r),(int)(256*g),(int)(256*b));
          strcpy(interp->result,result);
       } else if (strcmp(argv[3],"edge") == 0) {
          sprintf(result,"%d",[app valE]);
          strcpy(interp->result,result);
       } else if (strcmp(argv[3],"edgecolor") == 0) {
          sscanf([app valEColor]," %f %f %f ",&r,&g,&b);
        sprintf(result,"#%02x%02x%02x",(int)(256*r),(int)(256*g),(int)(256*b));
          strcpy(interp->result,result);
       } else {
           Tcl_AppendResult(interp, "bad decor tclval command \"",  argv[4],
            "\": should be face, edge, facecolor, or edgecolor", (char *)NULL);
           return TCL_ERROR;
       }
    } else if (strcmp(argv[1],"set") == 0) {
     
     /* Setting the whole world */       
       if (strcmp(argv[2],"world") == 0) {
          if (argc == 4) {
              decor = [decor makeDecorFromFile:argv[3]];
          }
          [decor printTclForGv];
          return TCL_OK;
       }

     /* Setting an individual object */
       if (argc < 5) {
         interp->result = "too few args";
         return TCL_ERROR;
       }
      key = argv[2];
      sprintf(appvar,"color(%s)",key);
      Tcl_LinkVar(interp,appvar,(char *)&appkey,TCL_LINK_STRING);
      code = Tcl_VarEval(interp,"newcolor ",key," default",(char *)NULL);
//      appkey = (char *)malloc(strlen(interp->result)+1);
//      strcpy(appkey,interp->result);  
       app = [basicDecor initEntry:appkey];    
       Tk_ParseArgv(interp,(Tk_Window )NULL,&argc,argv,argTable,0);       
       Tcl_UnlinkVar(interp,appvar);       
    } else if (strcmp(argv[1],"tclset") == 0) {
       if (argc != 7) {
         interp->result = "wrong # of args: should be <decor> tclset
             <appname> <faceon/off> <facecolor> <edgeon/off> <edgecolor>";
         return TCL_ERROR;
       }
       appkey = argv[2];
       app = [basicDecor initEntry:appkey];
       Tcl_SetVar2(interp,"color",appkey,appkey,TCL_GLOBAL_ONLY); 
       [app setF:(atof(argv[3]))];
       [app setE:(atoi(argv[5]))];

    /* Parse X-formatted color into appearance format */
       if (strlen(argv[4]) > 7) {
          sscanf(argv[4],"#%4x%4x%4x",&red,&green,&blue);
          r = (float)red/65536.;
          g = (float)green/65536.;
          b = (float)blue/65536.;
       } else {
          sscanf(argv[4],"#%2x%2x%2x",&red,&green,&blue);
          r = (float)red/256.;
          g = (float)green/256.;
          b = (float)blue/256.;      
       } 
       facecolor = (char *)malloc(40*(sizeof(char)));
       sprintf(facecolor," %f %f %f ",r,g,b);
       [app setFColor:facecolor];
       if (strlen(argv[6]) > 7) {
          sscanf(argv[6],"#%4x%4x%4x",&red,&green,&blue);
          r = (float)red/65536.;
          g = (float)green/65536.;
          b = (float)blue/65536.;
       } else {
          sscanf(argv[6],"#%2x%2x%2x",&red,&green,&blue);
          r = (float)red/256.;
          g = (float)green/256.;
          b = (float)blue/256.;      
       } 
       edgecolor = (char *)malloc(40*(sizeof(char)));
       sprintf(edgecolor," %f %f %f ",r,g,b);
       [app setEColor:edgecolor];        
    } else if (strcmp(argv[1],"print") == 0) {
         [decor print:stderr];
         fflush(togv);
    } else if (strcmp(argv[1],"newlights") == 0) {
       if (argc != 5) {
         interp->result = "wrong # of args: should be <decor> newlights                            <lightname1> <lightname2> <lightname3>";
         return TCL_ERROR;
       }
       light1 = [decor findFaceRGBforKey:argv[2]];
       l1pos = [decor findEdgeRGBforKey:argv[2]];
       light2 = [decor findFaceRGBforKey:argv[3]];
       l2pos = [decor findEdgeRGBforKey:argv[3]];
       light3 = [decor findFaceRGBforKey:argv[4]];
       l3pos = [decor findEdgeRGBforKey:argv[4]];
       fprintf(togv,"(merge-baseap appearance {lighting {replacelights ");
       fprintf(togv,"light {color %s",light1);
       fprintf(togv,"position %s 0.0}",l1pos);
       fprintf(togv,"light {color %s",light2);
       fprintf(togv,"position %s 0.0}",l2pos);
       fprintf(togv,"light {color %s",light3);
       fprintf(togv,"position %s 0.0}}})",l3pos);
       fflush(togv);
    } else {
       Tcl_AppendResult(interp, "bad decor command \"",
             argv[1],"\": should be value or set", (char *)NULL);
       return TCL_ERROR;
    }
    fflush(togv);
    return TCL_OK;
}


int quatProc(char *qvPtr, char *tablekey, char *nextArg) {
        Qvect *qv;
        float r,i,j,k;
        int matched;

     qv = [points findQforKey:nextArg];
     if (qv == NULL) {
           matched = sscanf(nextArg," %f %f %f %f ",&r,&i,&j,&k);   
           if (matched == 4) {
              qv = [[Qvect alloc] initWithR:r I:i J:j K:k];
           }           
       }
     if ((strstr(tablekey,"offset") != NULL) && (qv != NULL) && (qv1 != NULL)){
             qv = [qv1 sumWithD:qv];
     }
     *((Qvect **)qvPtr) = qv;
     return 1;
  }

int latProc(char *rPtr, char *tablekey, char *nextArg) {
    float theta;
    double r;

    theta = atof(nextArg);
    if (strstr(tablekey,"deg") != NULL) {
        theta = 2*(3.14159)*theta/360.;
        r = (double)cos(theta);
    } else r = (double)cos(theta);
    *((double *)rPtr) = r;
    return 1;
}

/* These #2 procedures don't print to Geomview */
 
int faceProc2(char *appPtr,char *tablekey, char *nextArg)   {
     App *app;
     char str[20];
     float r,g,b;
     int matched;

     app = *((App **)appPtr);    

   /*Create new app if a specific app for this object doesn't already exist*/ 
     if (strcmp(appkey,key) != 0) {
        app = [app copy];
        [basicDecor insertA:app Key:key];
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY); 
        strcpy(appkey,key);
     } 

       if (strcmp(nextArg,"on") == 0) {
              [app setF: 1];  
       }else if (strcmp(nextArg,"off") == 0) {
              [app setF:0];
       }else if (strstr(nextArg,"color") != NULL) {
              matched = sscanf(nextArg,"%s %f %f %f",str,&r,&g,&b);
              if (matched != 4) { 
	          fprintf(stderr,"-face color didn't parse properly");
		  return 1;
	      }      
              [app setF: 1];
	      sprintf(nextArg," %f %f %f ",r,g,b); 
              [app setFColor:nextArg];   
       }else {
               Tcl_AppendResult(Interp,"bad -face command \"",
                  nextArg,"\": should be on, off or color", (char *)NULL);
               return TCL_ERROR;
         }
   *((App **)appPtr) = app;
   return 1;   
}

int edgeProc2(char *appPtr, char *tablekey, char *nextArg) {
     App *app;
     char str[20];
     int matched,width;
     float r,g,b;
     
     app = *((App **)appPtr);

   /*Create new app if a specific app for this object doesn't already exist*/ 
     if (strcmp(appkey,key) != 0) {
        app = [app copy];
        [basicDecor insertA:app Key:key];
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY); 
        strcpy(appkey,key);
     } 

     if (strcmp(nextArg,"on") == 0) {
             [app setE:1];                    
        } else if (strcmp(nextArg,"off") == 0) {
               [app setE:0];
        } else if (strstr(nextArg,"width") != NULL) {
                matched = sscanf(nextArg,"%s %d",str,&width);
              if (matched != 2) {
	          fprintf(stderr,"-edge width didn't parse properly");
		  return 1;
	      }  
               [app setE:width];               
	} else if (strstr(nextArg,"color") != NULL) {
              matched = sscanf(nextArg,"%s %f %f %f",str,&r,&g,&b);
              if (matched != 4) {
	          fprintf(stderr,"-edge color didn't parse properly");
		  return 1;
	      }  
	      sprintf(nextArg," %f %f %f ",r,g,b);    
              [app setE: 1];  
              [app setEColor:nextArg];   
        } else {
               Tcl_AppendResult(Interp,"bad decor-set-object-edge command \"",
                  nextArg,"\": should be on,off,width or color", (char *)NULL);
               return TCL_ERROR;
        }
     *((App **)appPtr) = app;
     return 1;   
}

int transProc2(char *appPtr, char *tablekey, char *nextArg) {
     float alpha;
     App *app;
 
     app = *((App **)appPtr);
       
  /*Create new app if a specific app for this object doesn't already exist*/ 
     if (strcmp(appkey,key) != 0) {
        app = [app copy];
        [basicDecor insertA:app Key:key];
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY); 
        strcpy(appkey,key);
     } 

     alpha = atof(nextArg);
     if (alpha>=1) alpha = .95;
     [app setF:alpha];
     *((App **)appPtr) = app;
      return 1;
}


int diagCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
   Qlongt *diag,*result,*result2;
   Qvect *qv1,*qv2;
   char *col;
   App *app;
   int code;

   Tk_ArgvInfo argTable[] = {
     {"-face", TK_ARGV_FUNC, (char *)faceProc2, (char *)&app, 
                "Specify face appearance "}, 
     {"-edge", TK_ARGV_FUNC, (char *)edgeProc2, (char *)&app, 
                "Specify edge appearance "}, 		   	   
     {"-transparent", TK_ARGV_FUNC, (char *)transProc2, (char *)&app, 
                "Turn on transparancy"},
     {"-appearance", TK_ARGV_FUNC, (char *)appearProc, (char *)&app,
                "Specify an appearance by name"}, 		
     {"-quaternion",TK_ARGV_FUNC, (char *) quatProc, (char *)&qv1, 
                 "Specify quaternion value."},
     {"-q",TK_ARGV_FUNC, (char *) quatProc, (char *)&qv1, 
                 "Synonymos with -quaternion."},
     {"-quaternion2",TK_ARGV_FUNC, (char *) quatProc, (char *)&qv2,
                 "Specify second quaternion value"},
     {"-q2",TK_ARGV_FUNC, (char *) quatProc, (char *)&qv2, 
              "Synonymous with -quaternion2"},
     {"-q2offset",TK_ARGV_FUNC, (char *) quatProc, (char *)&qv2,
                  "Specify offset of second quaternion"},
     {(char *) NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,(char *) NULL}
   };

   Interp = interp;
   diag = (Qlongt *)clientData;
   app = [basicDecor initEntry:"diag"];
   qv1 = NULL; qv2 = NULL; 
   if (argc < 4) {
         interp->result = "Format: 'diag <operation> <quaternion> <name>'";
         return TCL_ERROR;
   } 
   key = argv[3];

 /* Make sure 'color' array is initialized */
   code = Tcl_VarEval(interp,"newcolor ",key," diag",(char *)NULL);
   appkey = (char *)malloc(strlen(interp->result)+1);
   strcpy(appkey,interp->result);

   quatProc((char *)&qv1,"-q",argv[2]);
   Tk_ParseArgv(interp,(Tk_Window )NULL,&argc,argv,argTable,0);

   if (strstr(argv[1],"conj") != NULL) {
      if (qv1 == NULL) {
         interp->result = "no quaternion value specified";
         return TCL_ERROR;
      }
      result = [diag diagConjBy:qv1];           
      [result printForGV:key];
      [result free];
   } else if (strstr(argv[1],"mult") != NULL) {
      if (qv1 == NULL) {
         interp->result = "no quaternion value specified";
         return TCL_ERROR;
      }
      if (qv2 == NULL) {
         result = [diag diagMultBy:qv1];
         [result printForGV:key];
      } else {
         result = [diag diagMultBy:qv1];
         result2 = [diag diagMultBy:qv2];
         appkey = Tcl_GetVar2(interp,"color",key,TCL_GLOBAL_ONLY);
         col = [basicDecor findFaceRGBforKey:appkey]; 
         [result printForGVwithOther:result2 Name:key Col:col];
         [result2 free];
      }
      [result free]; 
   } else {
       Tcl_AppendResult(interp, "bad diag command \"",
             argv[1],"\": should be longitude or hopf", (char *)NULL);
       return TCL_ERROR; 
   }
   [app printForGv:key];      
   fflush(togv);
   return TCL_OK;
}

int latCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv) {
    Qlongt *ijL,*ikL,*Theta;
    App *app;
    char *appkey,*col,*name;
    double r;
    int mesh, rots, code;

     Tk_ArgvInfo argTable[] = {
     {"-face", TK_ARGV_FUNC, (char *)faceProc2, (char *)&app, 
                "Specify face appearance "}, 
     {"-edge", TK_ARGV_FUNC, (char *)edgeProc2, (char *)&app, 
                "Specify edge appearance "}, 		   	   
     {"-transparent", TK_ARGV_FUNC, (char *)transProc2, (char *)&app, 
                "Turn on transparancy"},
     {"-appearance", TK_ARGV_FUNC, (char *)appearProc, (char *)&app,
                "Specify an appearance by name"}, 		
     {"-radians",TK_ARGV_FUNC, (char *) latProc, (char *)&r,
                  "Specify desired angle value of latitude in radians"},
     {"-degrees",TK_ARGV_FUNC, (char *) latProc, (char *)&r,
                  "Specify desired angle value of latitude in degrees"},
     {"-real",TK_ARGV_FLOAT,(char *)NULL,(char *)&r,
                  "Specify desired real value of latitude"},
     {"-mesh",TK_ARGV_INT,(char *)NULL,(char *)&mesh,
                  "Specify circle mesh"},
     {"-rotations",TK_ARGV_INT,(char *)NULL,(char *)&rots,
                   "Specify number of rotations in sphere"},
     {(char *) NULL, TK_ARGV_END, (char *) NULL, (char *) NULL,(char *) NULL}};
 
   Interp = interp;
   r = 0.0; mesh = 96; rots = 20;
   if (argc < 3) {
      interp->result = "too few arguments: must have 'latitude <type> <name>'";
         return TCL_ERROR;
   } 
   key = argv[2];

   if (strstr(argv[1],"sphere") != NULL) {

   /* Make sure app and 'color' are initialized and parse arguments */
      app = [basicDecor initEntry:"equator"];
      code = Tcl_VarEval(interp,"newcolor ",key," equator",(char *)NULL);
      appkey = (char *)malloc(strlen(interp->result)+1);
      strcpy(appkey,interp->result);  
      Tk_ParseArgv(interp,(Tk_Window )NULL,&argc,argv,argTable,0);

   /* Get face color for sphere */
       col = [basicDecor findEdgeRGBforKey:appkey];
      
   /* Create and print sphere */
      ijL = [[Qlongt alloc] initWithSize:mesh];
      ijL = [ijL makeIJGrCirc:r];
      [ijL printSphereRhoRotations:key numL:rots Col:col];
      fflush(togv);

   /* Free objects */
      [ijL free];
  } else if (strstr(argv[1],"ribs") != NULL) {

   /* Make sure app is initialized and parse arguments */
      app = [basicDecor initEntry:"eqribs"];
      code = Tcl_VarEval(interp,"newcolor ",key," eqribs",(char *)NULL);
      appkey = (char *)malloc(strlen(interp->result)+1);
      strcpy(appkey,interp->result);  
      Tk_ParseArgv(interp,(Tk_Window )NULL,&argc,argv,argTable,0);

   /* Get face color for ribs */
       col = [basicDecor findFaceRGBforKey:appkey];

   /* Create and print ribs */
      Theta =[[Qlongt alloc] initWithSize: mesh];
      ijL  = [[Qlongt alloc] initWithSize: mesh];
      ikL = [[Qlongt alloc] initWithSize: mesh];
      Theta = [Theta makeJKGrCirc:r];
      ijL = [ijL makeIJGrCirc:r];
      ikL= [ikL makeIKGrCirc:r];
      fprintf(togv,"(progn {define %s {LIST",key);
        name = strcat(key,"j");
      [Theta printForGVwithWidth:name Col:col];
        name = strcat(key,"i");
      [ijL printForGVwithWidth:name Col:col];
        name = strcat(key,"k");
      [ikL printForGVwithWidth:name Col:col];
      fprintf(togv,"}})");
      fflush(togv);

  /* Free objects */
      [Theta free]; [ijL free]; [ikL free];     
   } else {
       Tcl_AppendResult(interp, "bad latitude command \"",
             argv[1],"\": should be sphere or ribs", (char *)NULL);
       return TCL_ERROR; 
   }
   [app printForGv:key];      
   fflush(togv);
   return TCL_OK;
}










