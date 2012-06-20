/*   Hash Table for Axis-Angle Elements */
/*   Written by Rebecca Frankel    */

#import "group.h"
#import "qvect.h"
#import "qlongt.h"
#import "axang.h"
#import "aagrp.h"
#import <string.h>
#import <math.h>
#define PI 3.14159
#define togv stdout

int aagrpCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int axangCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);

@implementation AaGrp    

 /*Capitalized variables are instance variables*/
-init {
  Interp = NULL;
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);
  return self;
}

-initIn:(Tcl_Interp *)interp Name:(char *)name {
  Interp = interp;  
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);
/*  Tcl_CreateCommand(Interp, name, aagrpCmd,
                (ClientData)self,(Tcl_CmdDeleteProc *)NULL); */
  return self;
}
  
-(AxAng *)findAaForKey:(char *)key {
   Tcl_HashEntry *entryPtr;
 
   entryPtr = Tcl_FindHashEntry(&Table,key);
   return (AxAng *)Tcl_GetHashValue(entryPtr);
 }

-removeAaForKey:(char *)key {
   Tcl_HashEntry *entryPtr;
   AxAng *AA;
 
   entryPtr = Tcl_FindHashEntry(&Table,key);
   AA = (AxAng *)Tcl_GetHashValue(entryPtr);
   Tcl_DeleteHashEntry(entryPtr);
   [AA free];
   return self;
}

-insertAA:(AxAng *)aa Key:(char *)key {
   Tcl_HashEntry *entryPtr;
   int newPtr;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&newPtr);
   Tcl_SetHashValue(entryPtr,aa);
   return self;
}
   
-replaceAAatKey:(char *)key with:(AxAng *)aa {
   Tcl_HashEntry *entryPtr;
   int newPtr;
   
   entryPtr = Tcl_CreateHashEntry(&Table,key,&newPtr);
   Tcl_SetHashValue(entryPtr,aa);
   return self;
}
/* Note: These last two are exactly the same */

-initToCyclicOfOrder:(int)n {
  AxAng *up,*down;

  Interp = NULL;
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);

/* create cyclic */
  up = [[AxAng alloc] initWithAxisX:0 Y:0 Z:.05 Index:n];
  [up addtopX:.2 pY:0 pZ:0];
  down = [[AxAng alloc] initWithAxisX:0 Y:0 Z:-.05 Index:n];
  [down addtopX:.2 pY:0 pZ:0];
  [self insertAA:up Key:"f"];
  [self insertAA:down Key:"-f"];  
  return self;
}

-initToDihedralOfOrder:(int)n {
  AxAng *up,*down,*flip;
  int d;
  float x[25],y[25], xnext, ynext, theta;
  char key[10];

  Interp = NULL;
  Tcl_InitHashTable(&Table,TCL_STRING_KEYS);

/* create cyclic */
  up = [[AxAng alloc] initWithAxisX:0 Y:0 Z:.05 Index:n];
  [up addtopX:.2 pY:0 pZ:0];
  down = [[AxAng alloc] initWithAxisX:0 Y:0 Z:-.05 Index:n];
  [up addtopX:.2 pY:0 pZ:0];
  [self insertAA:up Key:"f"];
  [self insertAA:down Key:"-f"];  

/* create array of vertex values */
  for (d=0;d<n;d++) {
     theta = (float)d*2*3.14156/n; 
     x[d] = cos(theta); y[d] = sin(theta);
  }

/* add dihedral edge elements */
  for (d=0;d<n;d++) {
     xnext = x[(d+1)%n]; ynext = y[(d+1)%n];
     sprintf(key,"v%d",d);
     flip = [[AxAng alloc] initWithAxisX:x[d] Y:y[d] Z:0 Index:2];
     [flip setpX:(6*x[d]/7+xnext/7) pY:(6*y[d]/7+ynext/7) pZ:0.];
     [self insertAA:flip Key:key];

     sprintf(key,"e%d",d);
     flip = [[AxAng alloc] initWithAxisX:(x[d]+xnext)/2                                                               Y:(y[d]+ynext)/2 Z:0 Index:2];
     [flip setpX:(3*x[d]/7+4*xnext/7) pY:(3*y[d]/7+4*ynext/7) pZ:0.];     
     [self insertAA:flip Key:key];
  }
  return self;
}

-(char *)makeAaGrpFromOff:(char *)filename {
   FILE *off;
   float vx,vy,vz,sumx,sumy,sumz,px,py,pz;
   int v,f,m,mplus,nvert,nface,nedge,oface,e[6],edgecount,ind;   
   char str[5],test[15],edges[1000],vertices[250];
   char *grpinds;
   AxAng *aa,*aface[6];

   off = fopen(filename,"r");
   if (off == NULL) {
       fprintf(stderr,"Error opening %s",filename);
       return self;
       } 
   fscanf(off,"OFF\n");
   fscanf(off,"%d %d %d\n",&nvert,&nface,&nedge);
   ind = (2*nedge/nvert); /*Number of edges around each vertex*/
  
 /* Read axis of vertices and put in table */
 /* with Index = # of edges around vertex */ 
    for (v=0;v<nvert;v++) {
       fscanf(off,"%f %f %f\n",&vx,&vy,&vz);
       aa = [[AxAng alloc] initWithAxisX:vx Y:vy Z:vz Index:(float)ind];   
       sprintf(str,"v%d",v);
       [self insertAA:aa Key:str];
    /* if (Interp != NULL) {
          Tcl_CreateCommand(Interp,str,axAngCmd,
               (ClientData)aa,(Tcl_CmdDeleteProc *)NULL); 
       }*/
   }

 /* Read face specs and create face and edge axes */
   edgecount = 0;
   for (f=0;f<nface;f++) {
       fscanf(off,"%d",&oface); /* o for order */
       if (oface > 6) fprintf(stderr,"too many edges on face");
       sumx = 0; sumy = 0; sumz = 0; /*initialize sum*/

   /* Read face indices and make face axis */
   /* by adding vertex vectors around the face */
       for (m=0;m<oface;m++) {
           fscanf(off,"%d",&e[m]);
           sprintf(str,"v%d",e[m]);
           aface[m] = [self findAaForKey:str];
           vx = [aface[m] valX];
           vy = [aface[m] valY];
           vz = [aface[m] valZ];
           sumx = sumx + vx;
           sumy = sumy + vy;
           sumz = sumz + vz;
           }
       fscanf(off,"\n");
       sumx = sumx/oface; sumy = sumy/oface; sumz = sumz/oface;
   aa = [[AxAng alloc] initWithAxisX:sumx Y:sumy Z:sumz Index:(float)oface];  
      /* add a perpendicular coordinate */
       [aa addtopX:(vx-sumx)/7 pY:(vy-sumy)/7 pZ:(vz-sumz)/7];
       sprintf(str,"f%d",f);
       [self insertAA:aa Key:str];        
 
       /* Now make edge axes and list */
       /* being careful not to make duplicates */
       for (m=0;m<oface;m++) {
           mplus = (m + 1)%oface;
      
         /* test if edge already done */
         /* if not add to edge list */
           sprintf(test,"{%d %d}",e[m],e[mplus]);
           if (strstr(edges,test) != NULL) continue;  
           sprintf(edges,"%s%s",edges,test);

        /* do the same in the other order */
           sprintf(test,"{%d %d}",e[mplus],e[m]);
           if (strstr(edges,test) != NULL) continue;  
           sprintf(edges,"%s%s",edges,test);
           
        /* Average values for edge and put in group */
           vx = ([aface[m] valX] + [aface[mplus] valX])/2;
           vy = ([aface[m] valY] + [aface[mplus] valY])/2;
           vz = ([aface[m] valZ] + [aface[mplus] valZ])/2;
           px = 4*[aface[m] valX]/7 + 3*[aface[mplus] valX]/7;
           py = 4*[aface[m] valY]/7 + 3*[aface[mplus] valY]/7;
           pz = 4*[aface[m] valZ]/7 + 3*[aface[mplus] valZ]/7;

           aa = [[AxAng alloc] initWithAxisX:vx Y:vy Z:vz Index:2.];
           [aa setpX:px pY:py pZ:pz];
           sprintf(str,"e%d",edgecount);
           [self insertAA:aa Key:str];
           edgecount++;

         /* test if vertex perpendicular already done */
         /* if not add to vertices list */
           sprintf(test,"{%d}",e[m]);
           if (strstr(vertices,test) != NULL) {
             /* test if other perp done */
                    sprintf(test,"{%d}",e[mplus]);
                    if (strstr(vertices,test) != NULL) continue;  
                    px = 6*[aface[mplus] valX]/7 + [aface[m] valX]/7;
                    py = 6*[aface[mplus] valY]/7 + [aface[m] valY]/7;
                    pz = 6*[aface[mplus] valZ]/7 + [aface[m] valZ]/7;
                    [aface[mplus] setpX:px pY:py pZ:pz];
           } else {
                    px = 6*[aface[m] valX]/7 + [aface[mplus] valX]/7;
                    py = 6*[aface[m] valY]/7 + [aface[mplus] valY]/7;
                    pz = 6*[aface[m] valZ]/7 + [aface[mplus] valZ]/7;
                    [aface[m] setpX:px pY:py pZ:pz];
           }         
           sprintf(vertices,"%s%s",vertices,test);
       }        
   }
   grpinds = (char *)malloc(12*sizeof(char));    
   if (ind>oface) sprintf(grpinds,"{2 %d %d}",oface,ind);
         else sprintf(grpinds,"{2 %d %d}",ind,oface);
   return grpinds;
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

-free {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   AxAng *aa;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     aa = Tcl_GetHashValue(entryPtr);
     aa = [aa free];
     entryPtr = Tcl_NextHashEntry(&search);
   }
   Tcl_DeleteHashTable(&Table);   
   return TCL_OK;
}  
   
-print {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *key; 
   AxAng *aa;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     key = Tcl_GetHashKey(&Table,entryPtr);
     aa = (AxAng *) Tcl_GetHashValue(entryPtr);
     printf("%s    ",key);
     printf("Axis X:%f  Y:%f  Z:%f ",[aa valX],[aa valY],[aa valZ]);
     printf("        Angle:%f\n",[aa valAng]);
     entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

-printForEuclGV:(Tcl_Channel)toGv {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *str,key[10],temp[300];
   int ind,i;
   float angle,x,y,z,px,py,pz; 
   AxAng *aa;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     str = Tcl_GetHashKey(&Table,entryPtr);
     aa = (AxAng *) Tcl_GetHashValue(entryPtr);
     x = [aa valX]; y = [aa valY]; z = [aa valZ];
     px = [aa valpX]; py = [aa valpY]; pz = [aa valpZ];

   sprintf(temp, "(read geometry {define %s ", str);
   Tcl_Write(toGv, temp,-1);
   Tcl_Write(toGv, "VECT \n",-1);
   Tcl_Write(toGv, "1 3 0 \n",-1); /*1 line, 3 verts, 0 colors*/
   Tcl_Write(toGv, "3 0 \n",-1);  /*3 verts in line, 0 colors*/
   Tcl_Write(toGv, "0 0 0 \n",-1); /*First point coords*/
   sprintf(temp, "%f %f %f \n",x,y,z); /*second point coords*/
   Tcl_Write(toGv,temp,-1);
   sprintf(temp, "%f %f %f \n",px,py,pz); /*third point coords*/
   Tcl_Write(toGv,temp,-1);
   Tcl_Write(toGv, "})\n",-1);
   sprintf(temp, "(geometry %s {:%s})\n",str,str);
   Tcl_Write(toGv,temp,-1);
   sprintf(temp,"(merge-ap %s appearance { material {",str);
   Tcl_Write(toGv,temp,-1);
   Tcl_Write(toGv," *edgecolor  .103 .239 .889}})",-1);
   Tcl_Flush(toGv);

     ind = [aa valInd];
     for (i=1;i<ind;i++) {
       angle = i*(2*PI)/ind;
       [aa setAng:angle];
       sprintf(key,"%s^%d",str,i);
       [aa printTransForGV:key to:toGv];
        sprintf(temp, "(read geometry {define %s ",key);
	Tcl_Write(toGv,temp,-1);
        Tcl_Write(toGv, "VECT \n",-1);
        Tcl_Write(toGv, "1 3 0 \n",-1); /*1 line, 3 verts, 0 colors*/
        Tcl_Write(toGv, "3 0 \n",-1);  /*3 verts in line, 0 colors*/
        Tcl_Write(toGv, "0 0 0 \n",-1); /*First point coords*/
        sprintf(temp, "%f %f %f \n",x,y,z); /*second point coords*/
	Tcl_Write(toGv,temp,-1);
        sprintf(temp, "%f %f %f \n",px,py,pz); /*third point coords*/
	Tcl_Write(toGv,temp,-1);
        Tcl_Write(toGv, "})\n",-1);
        sprintf(temp, "(geometry %s {:%s})\n",key,key);
	Tcl_Write(toGv,temp,-1);
        sprintf(temp,"(xform %s {:t%s})",key,key); 
	Tcl_Write(toGv,temp,-1);
      }
      [aa setAng:ind];
      entryPtr = Tcl_NextHashEntry(&search);
   }   
   return self;
}

-convertAaGrpTo:(Group *)QGrp {
   Tcl_HashEntry *entryPtr;
   Tcl_HashSearch search;
   char *str,key[10]; 
   int ind,i;
   float angle;
   AxAng *aa;
   Qvect *qv,*one,*minusone;

   entryPtr = Tcl_FirstHashEntry(&Table,&search);
   while(entryPtr != NULL) {
     str = Tcl_GetHashKey(&Table,entryPtr);
     aa = (AxAng *) Tcl_GetHashValue(entryPtr);
     ind = [aa valInd];
     for (i=1;i<ind;i++) {
       angle = i*(2*PI)/ind;
       [aa setAng:angle];
       qv = [aa convertToQ];
       sprintf(key,"%s^%d",str,i);
       [QGrp insertQ:qv  Key:key];         
     } 
     [aa setAng:ind];  
     entryPtr = Tcl_NextHashEntry(&search);
   }

 /* The preceding algorithm neglected to include one and minus one */
   one = [[Qvect alloc] initWithR:1 I:0 J:0 K:0];
   minusone = [[Qvect alloc] initWithR:-1 I:0 J:0 K:0];   
   [QGrp insertQ:one Key:"one"];
   [QGrp insertQ:minusone Key:"-one"];
   return self;
}

@end




