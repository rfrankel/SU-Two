/*   Hash Table for Appearances */
/*   Written by Rebecca Frankel    */

#import "appear.h"
#import "include.h"
#import "decor.h"
#import <string.h>
#import <math.h>
#import <stdlib.h>
#define togv stdout

int decorCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);

@implementation Decor

/*Capitolized variables are instance variables*/
-init {
  Interp = NULL;
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);
  return self;
}

-initIn:(Tcl_Interp *)interp Name:(char *)name {
  Interp = interp;  
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);
  Tcl_CreateCommand(Interp, name, decorCmd,
                (ClientData)self,(Tcl_CmdDeleteProc *)NULL);
  return self;
}

-(App *)initEntry:(char *)key {
   Tcl_HashEntry *entryPtr;
   App *app;
   int new;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&new);
   if (new) {
     app = [[App alloc] init];
     Tcl_SetHashValue(entryPtr,app);
     if (Interp != NULL) {
        Tcl_SetVar2(Interp,"color",key,key,TCL_GLOBAL_ONLY);
     }
   } else app = (App *)Tcl_GetHashValue(entryPtr);
   return app;  
}

-(App *)findAforKey:(char *)key {
   Tcl_HashEntry *entryPtr;
 
   entryPtr = Tcl_FindHashEntry(&Table,key);
   if (entryPtr != NULL) {
     return (App *)Tcl_GetHashValue(entryPtr);
   }
   fprintf(stderr,"no entry for key: %s",key);
   return NULL;
}

-(char *)findFaceRGBforKey:(char *)key {
  Tcl_HashEntry *entryPtr;
  App *app; 

   entryPtr = Tcl_FindHashEntry(&Table,key);
   if (entryPtr != NULL) {
   app = (App *)Tcl_GetHashValue(entryPtr);
   return [app valFColor];
   } else {
   fprintf(stderr,"no entry for key: %s",key);
   return " 0.0 0.0 0.0 ";
   }
}

-(char *)findEdgeRGBforKey:(char *)key {
  Tcl_HashEntry *entryPtr;
  App *app; 

   entryPtr = Tcl_FindHashEntry(&Table,key);
   if (entryPtr != NULL) {
   app = (App *)Tcl_GetHashValue(entryPtr);
   }
   return [app valEColor];
}
  
-removeAforKey:(char *)key {
   Tcl_HashEntry *entryPtr;
   App *A;
 
   entryPtr = Tcl_FindHashEntry(&Table,key);
   A = (App *)Tcl_GetHashValue(entryPtr);
   Tcl_DeleteHashEntry(entryPtr);
   [A free];
   return self;
}

-insertA:(App *)app Key:(char *)key {
   Tcl_HashEntry *entryPtr;
   int newPtr;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&newPtr);
   Tcl_SetHashValue(entryPtr,app);
   return self;
}

-replaceAatKey:(char *)key with:(App *)app {
   Tcl_HashEntry *entryPtr;
   int newPtr;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&newPtr);
   Tcl_SetHashValue(entryPtr,app);
   return self;
}
/* Note: These last two are exactly the same */   

-(int)listKeys {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key; 

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     if (Interp != NULL) {
       Tcl_AppendElement(Interp,key);
       } 
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return TCL_OK;
}  

-makeDecorFromFile:(char *)filename {
   FILE *grpels;
   float er,eg,eb,fr,fg,fb,face;
   int edge;   
   char str[15],*fRGB,*eRGB;
   App *app;

   grpels = fopen(filename,"r");
   if (grpels == NULL) {
       fprintf(stderr,"Error opening %s",filename);
       return self;
   }
   while (fscanf(grpels,"%s\n",str) != EOF) {
     fscanf(grpels,"%f face %f %f %f\n",&face,&fr,&fg,&fb);
     fscanf(grpels,"%d edge %f %f %f\n",&edge,&er,&eg,&eb);
     fRGB = (char *)malloc(20*(sizeof(char *)));
     sprintf(fRGB," %4f %4f %4f ",fr,fg,fb);
     eRGB = (char *)malloc(20*(sizeof(char *)));
     sprintf(eRGB," %4f %4f %4f ",er,eg,eb);
     app = [[App alloc] initWithF:face FaceRGB:fRGB E:edge EdgeRGB:eRGB]; 
     if (strstr(str,"light") != NULL) [app setType:LIGHT];
     if (strstr(str,"Cam") != NULL) [app setType:CAM];
     [self insertA:app Key:str];
     if (Interp != NULL) {
        Tcl_SetVar2(Interp,"color",str,str,TCL_GLOBAL_ONLY);
     }
   }
   return self;
}


-free {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   App *app;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     app = Tcl_GetHashValue(entryPtr);
     app = [app free];
     entryPtr = Tcl_NextHashEntry(&search);
   }
   Tcl_DeleteHashTable(&Table);   
   return TCL_OK;
}

-print:(FILE *)file {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key; 
   App *app;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     app = (App *) Tcl_GetHashValue(entryPtr);
     printf("%s   \n",key);
     [app print:file];
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

-printForGv {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key,*lcol[3],*lpos[3];
   int lightcount;
   App *app;

   lightcount = 0;
   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     app = (App *) Tcl_GetHashValue(entryPtr);
      if ([app valType] == LIGHT) { 
         lcol[lightcount] = [app valFColor];
         lpos[lightcount] = [app valEColor];
         if (lightcount == 3) {
           fprintf(togv,"(merge-baseap appearance {lighting {replacelights ");
           fprintf(togv,"light {color %s",lcol[0]);
           fprintf(togv,"position %s 0.0}",lpos[0]);
           fprintf(togv,"light {color %s",lcol[1]);
           fprintf(togv,"position %s 0.0}",lpos[1]);
           fprintf(togv,"light {color %s",lcol[2]);
           fprintf(togv,"position %s 0.0}}})",lpos[2]);
           lightcount = 0;
         }  
         lightcount++;
       } else [app printForGv:key];
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

-printTclForGv {
   char *key,*appkey,*lcol[3],*lpos[3],**argv;
   int lightcount,code,argc,a;
   App *app;

   lightcount = 0;
   if (Interp != NULL) {
      code = Tcl_VarEval(Interp,"array ","names ","color",(char *)NULL);
      if (code == TCL_ERROR) { 
         fprintf(stderr,"Error: can't access array color");
         return self;
      }
      code =  Tcl_SplitList(Interp,Interp->result,&argc,&argv);
      if (code == TCL_ERROR) { 
         fprintf(stderr,"Error printing decor from Tcl");
         return self;
      }
   } else {
      fprintf(stderr,"Error printing decor from Tcl: no interp defined");
      return self;
   }
   for (a=0;a<argc;a++) {
     key = argv[a];
     appkey = Tcl_GetVar2(Interp,"color",key,TCL_GLOBAL_ONLY);
     if (appkey == NULL) { 
         fprintf(stderr,"Error: element %s is not in array color",key);
         continue;
     }
     app = [self findAforKey:appkey];
     if (app == NULL) {
       fprintf(stderr,"Error: %s's value %s not in decor table",key,appkey);
       continue;
     }
     if ([app valType] == LIGHT) { 
         lcol[lightcount] = [app valFColor];
         lpos[lightcount] = [app valEColor];
         if (lightcount == 3) {
           fprintf(togv,"(merge-baseap appearance {lighting {replacelights ");
           fprintf(togv,"light {color %s",lcol[0]);
           fprintf(togv,"position %s 0.0}",lpos[0]);
           fprintf(togv,"light {color %s",lcol[1]);
           fprintf(togv,"position %s 0.0}",lpos[1]);
           fprintf(togv,"light {color %s",lcol[2]);
           fprintf(togv,"position %s 0.0}}})",lpos[2]);
           lightcount = 0;
         }  
         lightcount++;
       } else [app printForGv:key];
   }   
   free(&argv);
   return self;
}

-printForEuclGv:(FILE *)toGv {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key,*lcol[3],*lpos[3];
   int lightcount;
   App *app;

   lightcount = 0;
   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     app = (App *) Tcl_GetHashValue(entryPtr);
      if ([app valType] == LIGHT) { 
         lcol[lightcount] = [app valFColor];
         lpos[lightcount] = [app valEColor];
         if (lightcount == 3) {
           fprintf(togv,"(merge-baseap appearance {lighting {replacelights ");
           fprintf(togv,"light {color %s",lcol[0]);
           fprintf(togv,"position %s 0.0}",lpos[0]);
           fprintf(togv,"light {color %s",lcol[1]);
           fprintf(togv,"position %s 0.0}",lpos[1]);
           fprintf(togv,"light {color %s",lcol[2]);
           fprintf(togv,"position %s 0.0}}})",lpos[2]);
           lightcount = 0;
         }  
         lightcount++;
       } else [app printForGv:key To:toGv];
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

@end



