/*   Hash Table for Group Elements */
/*   Written by Rebecca Frankel    */

#import "group.h"
#import "qvect.h"
#import "qlongt.h"
#import <string.h>
#import <math.h>
#define PI 3.14159
#define togv stdout

int groupCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int qvectCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);

@implementation Group    


 /*Capitolized variables are instance variables*/
-init {
  Interp = NULL;
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);
  return self;
}

-initIn:(Tcl_Interp *)interp Name:(char *)name {
  Interp = interp;  
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);
  Tcl_CreateCommand(Interp, name, groupCmd,
                (ClientData)self,(Tcl_CmdDeleteProc *)NULL);
  return self;
}

-(Qvect *)findQforKey:(char *)key {
   Tcl_HashEntry *entryPtr;
 
   entryPtr = Tcl_FindHashEntry(&Table,key);
   if (entryPtr == NULL) return NULL;
   return (Qvect *)Tcl_GetHashValue(entryPtr);
 }

-removeQforKey:(char *)key {
   Tcl_HashEntry *entryPtr;
   Qvect *Q;
 
   entryPtr = Tcl_FindHashEntry(&Table,key);
   Q = (Qvect *)Tcl_GetHashValue(entryPtr);
   Tcl_DeleteHashEntry(entryPtr);
   [Q free];
   return self;
}

-insertQ:(Qvect *)qv Key:(char *)key {
   Tcl_HashEntry *entryPtr;
   int newPtr;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&newPtr);
   Tcl_SetHashValue(entryPtr,qv);
   return self;
}
   
-replaceQatKey:(char *)key with:(Qvect *)qv {
   Tcl_HashEntry *entryPtr;
   int newPtr;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&newPtr);
   Tcl_SetHashValue(entryPtr,qv);
   return self;
}
/* Note: These last two are exactly the same */

-(Tcl_HashTable)getTable {
   return Table;
}

-makeGroupFromFile:(char *)filename {
   FILE *grpels;
   float r,i,j,k;   
   char str[10];
   Qvect *qEl;

   grpels = fopen(filename,"r");
   if (grpels == NULL) {
       fprintf(stderr,"Error opening %s",filename);
       return self;
   }
   while (fscanf(grpels,"%s %f %f %f %f\n",str,&r,&i,&j,&k) != EOF) {
     qEl = [[Qvect alloc] initToZero];
     [qEl setReal:r]; [qEl setI:i]; [qEl setJ:j]; [qEl setK:k];
     [self insertQ:qEl Key:str];
     if (Interp != NULL) {
       Tcl_CreateCommand(Interp,str,qvectCmd,
               (ClientData)qEl,(Tcl_CmdDeleteProc *)NULL);
     }
   }
   return self;
 }

-(int)listGrp {
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

/* This procedure is to find which group point is nearest some
arbitrary point which may not fall exactly on top of any particular
point */
 
-(char *)nearestPoint:(Qvect *)qv {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *nearest;
   Qvect *point;
   float r,i,j,k,least;
   
   least = 3;
   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     point = Tcl_GetHashValue(entryPtr);
     r = fabs([point valReal] - [qv valReal]);
     i = fabs([point valI] - [qv valI]);
     j = fabs([point valJ] - [qv valJ]);
     k = fabs([point valK] - [qv valK]);
  /* I don't bother to sum squares and take square root */
     if (r+i+j+k > least) goto nextloop;     
       else least = r+i+j+k;     
     nearest = Tcl_GetHashKey(&Table,entryPtr);
 nextloop: entryPtr = Tcl_NextHashEntry(&search);
   }
   return nearest;
}

/* This procedure assumes a closer match than the last one:
it is for matching a point which is nearly exactly on some group
point except for maybe a little numerical error */

-(char *)matchPoint:(Qvect *)qv {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *nearest;
   Qvect *point;
   float r,i,j,k,least;
   
   least = 1; nearest = "";
   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     point = Tcl_GetHashValue(entryPtr);
     r = fabs([point valReal] - [qv valReal]);
       if (r > .01) goto nextloop;
     i = fabs([point valI] - [qv valI]);
       if (i > .01) goto nextloop;
     j = fabs([point valJ] - [qv valJ]);
       if (j > .01) goto nextloop;
     k = fabs([point valK] - [qv valK]);
       if (k > .01) goto nextloop;
     nearest = Tcl_GetHashKey(&Table,entryPtr);
 nextloop: entryPtr = Tcl_NextHashEntry(&search);
   }
   if (nearest == "") {
         fprintf(stderr,"no point matches"); 
         nearest = Tcl_GetHashKey(&Table,Tcl_FirstHashEntry(&Table,&search));
      /*(just so as to return something that won't cause errors elsewhere */
   }
   return nearest;
}

-free {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   Qvect *qv;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     qv = Tcl_GetHashValue(entryPtr);
     qv = [qv free];
     entryPtr = Tcl_NextHashEntry(&search);
   }
   Tcl_DeleteHashTable(&Table);   
   return TCL_OK;
}  
   

-print {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key; 
   Qvect *qv;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     qv = (Qvect *) Tcl_GetHashValue(entryPtr);
     printf("%s    ",key);
     printf("%f  %f  ",[qv valReal],[qv valI]);
     printf("%f  %f  \n",[qv valJ],[qv valK]);
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

-printForGVasPointswithCol:(char *)col{
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key; 
   Qvect *qv;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     qv = (Qvect *) Tcl_GetHashValue(entryPtr);
     fprintf(togv, "(read geometry { define %s \n",key);  
     fprintf(togv,"4VECT\n");
     fprintf(togv,"1 1 0\n"); /*Nlines,Nverts,Ncolors*/
     fprintf(togv,"1\n"); /*no. vertices in each line*/
     fprintf(togv,"0\n"); /*no. colors in each line */
     fprintf(togv,"%f %f ",[qv valK],[qv valJ]);
     fprintf(togv,"%f %f\n",[qv valI],[qv valReal]);
     fprintf(togv,"})\n");
     fprintf(togv, "(geometry %s {:%s})\n",key,key);
     fprintf(togv,"(merge-ap %s appearance { linewidth 7 material ",key);
     fprintf(togv,"{edgecolor %s}})\n",col);
     fflush(togv);   
     entryPtr = Tcl_NextHashEntry(&search);
   }
   return self;
}
  
-printForGVwithSize:(unsigned)m Col:(char *)col{
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key; 
   Qvect *qv;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     qv = (Qvect *) Tcl_GetHashValue(entryPtr);
     [qv printForGVwithName:(char*)key Size:m Col:col];  
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

-printForEuclGV:(FILE *)toGv {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key[100];
   Qvect *qv;
   int c,count;

   count = 0;
   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key[count] = Tcl_GetHashKey(&Table,entryPtr);
     qv = (Qvect *) Tcl_GetHashValue(entryPtr);
     [qv printTransfForGV:key[count] to:toGv];  
     entryPtr = Tcl_NextHashEntry(&search);
     count++;
   }   

   fprintf(toGv, "(read geometry {define axis "); 
   fprintf(toGv, "VECT \n");
   fprintf(toGv, "1 3 0 \n"); /*1 line, 3 verts, 0 colors*/
   fprintf(toGv, "3 0 \n");  /*3 verts in line, 0 colors*/
   fprintf(toGv, "0 0 0 \n"); /*First point coords*/
   fprintf(toGv, "0 0 1 \n"); /*second point coords*/
   fprintf(toGv, ".2 0 1 \n"); /*third point coords*/
   fprintf(toGv, "})\n");
   fprintf(toGv, "(geometry axis {:axis})\n");

   fprintf(toGv,"(read geometry {define group \n");
   fprintf(toGv,"INST\n");
   fprintf(toGv,"geom {:axis}\n");
   fprintf(toGv,"transforms {TLIST\n");
   for(c=0;c<count;c++) {
      fprintf(toGv,"{:%s}",key[c]);
   }
   fprintf(toGv,"}})");
   fprintf(toGv,"(geometry group {:group})");
   fflush(toGv);
   return self;
}

@end




