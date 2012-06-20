/*   Object for creating OOGL files in spherical space  */
/*    Longitudes of SU2   */
/*    Written by Rebecca Frankel */

#import "qlongt.h"
#import <stdio.h>
#import <math.h>
#import "tcl.h"
#define PI 3.14159
#define togv stdout 

int diagCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);
int latCmd(ClientData clientData, Tcl_Interp *interp,
         int argc, char **argv);


@implementation Qlongt

/* Inherits numElements */
/* and maxElements from List */

-initWithSize:(unsigned)n {
   [self initCount:n];
   return self;
}

-initToZeroWithSize:(unsigned)n {
   int j;

   [self initCount:n];
   for (j=0;j<n;j++) {
     [self addObject:[[Qvect alloc] initToZero]];
   }
   return self;  
} 

-(Qvect *)addQ:(Qvect *)q {
  return [self addObject:q];
}

-(Qvect *)getQatVert:(unsigned)index {  
  return [[self objectAt:index] stupidCopy];
}

-(Qvect *)getQatVertD:(unsigned)index {
  return [self objectAt:index];
}

-(Qvect *)replaceQatVert:(unsigned)index with:(Qvect *)Q {
  return [self replaceObjectAt:index with:Q];
}  /* this replaces and returns the old object */

-free {
   [self freeObjects];
   return [super free];
} 

-(Qlongt *)makeDiagLongt {
  float theta;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    qvj = [[Qvect alloc] initWithR:cos(theta) I:sin(theta) J:0 K:0];
    [self addQ:qvj];   
   }  
   return self;
}

-(Qlongt *)makeDiagLongtIn:(Tcl_Interp *)interp {
  float theta;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    qvj = [[Qvect alloc] initWithR:cos(theta) I:sin(theta) J:0 K:0];
    [self addQ:qvj];   
   }  
   Tcl_CreateCommand(interp, "diag", diagCmd,
                (ClientData)self,(Tcl_CmdDeleteProc *)NULL);
   Tcl_CreateCommand(interp, "latitude", latCmd,
                (ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
   return self;
}

-(Qlongt *)diagConjBy:(Qvect *)qvP {
  float theta;
  int j,maxElements;
  Qvect *qvj,*qvB;
  Qlongt *result;

  maxElements = self->maxElements;
  result = [[Qlongt alloc] initWithSize: maxElements]; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;
    qvj = [self getQatVertD: j];  
    qvB = [qvj conjBy: qvP];
    [result addQ:qvB];
   }  
   return result;
}	

-(Qlongt *)diagMultBy:(Qvect *)qvP {
  float theta;
  int j,maxElements;
  Qvect *qvj,*qvB;
  Qlongt *result;

  maxElements = self->maxElements;
  result = [[Qlongt alloc] initWithSize: maxElements]; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;
    qvj = [self getQatVertD: j];  
    qvB = [qvj prodWith: qvP];
    [result addQ:qvB];
   }  
   return result;
}	

-(Qlongt *)makeJLongt {
  float theta;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    qvj = [[Qvect alloc] initWithR:sin(theta) I:0 J:cos(theta) K:0];
    [self addQ:qvj];   
   }  
  return self;
}

-(Qlongt *)makeKLongt {
  float theta;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    qvj = [[Qvect alloc] initWithR:sin(theta) I:0 J:0 K:cos(theta)];
    [self addQ:qvj];   
   }  
  return self;
}

-(Qlongt *)makeJKGrCirc:(float)r {
  float theta;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    qvj = [[Qvect alloc] initWithR:r I:0 J:sin(theta) K:cos(theta)];
    [self addQ:qvj];   
   }  
  return self;
}

-(Qlongt *)makeIJGrCirc:(float)r {
  float theta,phi,s;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    phi = acos(r);
    s = sin(phi);
    qvj = [[Qvect alloc] initWithR:r I:s*sin(theta) J:s*cos(theta) K:0];
    [self addQ:qvj];   
   }  
  return self;
}

-(Qlongt *)makeIKGrCirc:(float)r {
  float theta;
  int j,maxElements;
  Qvect *qvj;

  maxElements = self->maxElements; 
  for (j=0; j<maxElements; j++) {
    theta = (2*PI/maxElements)*j;  
    qvj = [[Qvect alloc] initWithR:r I:sin(theta) J:0 K:cos(theta)];
    [self addQ:qvj];   
   }  
  return self;
}

-(Qlongt *)rotateRhoGC:(unsigned)n :(unsigned)m {
   float rho;
   Qlongt *GCnm;
   Qvect *qvP,*qvA, *qvB;
   int j,maxElements;

   numElements = self->numElements;
   GCnm =[[Qlongt alloc] initWithSize:numElements];
   qvP = [[Qvect alloc] initToZero];   
   rho = (PI/m)*n;
   [qvP setReal:cos(rho)];
   [qvP setJ:sin(rho)];
   for (j=0;j<numElements;j++) {
     qvA = [self getQatVertD:j];
     qvB = [qvA conjBy: qvP];
     [GCnm addQ:qvB];
     }
   qvP = [qvP free];
   return GCnm;
} 

/* Note: Prints R,I,J,K in reverse order because */
/* CS matrices are the transpose of math matrices. */
/* Actually, I'm still not sure what they should be */

- printForOOGL {
   Qvect *qvj;
   int j,numElements;
   
   numElements = self->numElements;
   for (j=0;j<numElements;j++) {
   qvj = [self getQatVertD: j];
   fprintf(togv,"%f  %f  ",[qvj valK],[qvj valJ]);
   fprintf(togv,"%f  %f  \t",[qvj valI],[qvj valReal]);
   }
   return self;
}

- printForOOGLeveryOther {
   Qvect *qvj;
   int j,numElements;
   
   numElements = self->numElements;
   for (j=0;j<numElements;j = j+2) {
   qvj = [self getQatVertD: j];
   fprintf(togv,"%f  %f  ",[qvj valK],[qvj valJ]);
   fprintf(togv,"%f  %f  \t",[qvj valI],[qvj valReal]);
   }
   return self;
}

-printForOOGLwithEpsilon:(float)e {
   Qvect *qvj;
   int j,numElements;
   
   numElements = self->numElements;
   for (j=0;j<numElements;j++) {
   qvj = [self getQatVertD: j];
   fprintf(togv,"%f  %f  ",[qvj valK]+e,[qvj valJ]+e);
   fprintf(togv,"%f  %f  \t",[qvj valI]+e,[qvj valReal]);
   }
   return self;
}

- printForGVwithWidth:(char *) name Col:(char *)col{

   fprintf(togv, "(geometry %s {: %s })\n",name,name);
   fflush(togv);
   fprintf(togv, "(read geometry { define %s \n",name);
   fprintf(togv,"4uMESH\n"); 
   fprintf(togv,"%d 2\n",numElements);  
   [self printForOOGL];
   [self printForOOGLwithEpsilon:.08];
   fprintf(togv,"\n})\n");
  fprintf(togv,"(merge-ap %s appearance { * face material {",name);
  fprintf(togv,"ambient %s",col);
  fprintf(togv,"*diffuse %s}})",col);
   fflush(togv);
   return self;
}

-printForGVwithOther:(Qlongt *)qlongt Name:(char *)name Col:(char *)col {

   fprintf(togv, "(geometry %s {: %s })\n",name,name);
   fflush(togv);
   fprintf(togv, "(read geometry { define %s \n",name);
   fprintf(togv,"4uMESH\n"); 
   fprintf(togv,"%d 2\n",numElements);  
   [self printForOOGL];
   [qlongt printForOOGL];
   fprintf(togv,"\n})\n");
  fprintf(togv,"(merge-ap %s appearance { * face material {",name);
  fprintf(togv,"ambient %s",col);
  fprintf(togv,"*diffuse %s}})",col);
   fflush(togv);
   return self;
 }
 
-printForGV:(char*) name {
   fprintf(togv, "(geometry %s {: %s })\n",name,name);
   fflush(togv);
   fprintf(togv, "(read geometry { define %s \n",name);
   fprintf(togv,"4uMESH\n"); 
   fprintf(togv,"%d 2\n",numElements);  
   [self printForOOGL];
   [self printForOOGL];
   fprintf(togv,"\n})\n");
   fprintf(togv,"(merge-ap %s {appearance {-face +edge linewidth 3}})\n",name);
   fflush(togv);
   return self;
}

-printSphereRhoRotations:(char *)name numL:(unsigned)nL Col:(char *)col{
   Qlongt *Rho;
   int i;

   fprintf(togv, "(geometry %s {:%s})\n",name,name);
   fflush(togv);
   fprintf(togv, "(read geometry { define %s \n",name);  
   fprintf(togv,"4vMESH\n");
   fprintf(togv,"%d %d\n",numElements/2,nL);
   for (i=0;i<nL;i++) {
     Rho = [self  rotateRhoGC:i :nL];
     [Rho printForOOGLeveryOther];
     fprintf(togv,"\n");
   }
   fprintf(togv,"})\n");
   fprintf(togv,"(merge-ap %s {appearance {-face +edge ",name);
   fprintf(togv,"linewidth 3 material {edgecolor %s}}})\n",col);
   fflush(togv);
   Rho = [Rho free];
   return self;
 }

@end








