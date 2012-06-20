/* Object approximating Quaternion Vectors */
/*   Written by Rebecca Frankel            */
#import "qvect.h"
#import <math.h>
#import <stdio.h>
#import "axang.h"
#define PI 3.14159
#define togv stdout

@implementation Qvect:Object
{float R,I,J,K;
}

-initToZero {
   R=0.0; I=0.0; J=0.0; K=0.0;
   return self;
}

-initWithR:(float)r I:(float)i J:(float)j K:(float)k {
   R=r; I=i; J=j; K=k;
   return self;
}

-(float)valReal {
   return R;
}

-(float)valI {
   return I;
}

-(float)valJ {
   return J;
}

-(float)valK {
   return K;
}


-setReal:(float)num {
   R = num;
   return self;
}

-setI: (float)num {
   I = num;
   return self;
}

-setJ: (float)num {
   J = num;
   return self;
}

-setK: (float)num {
   K = num;
   return self;
}

-setR:(float)r I:(float)i J:(float)j K:(float)k {
   R = r; I = i; J = j; K = k;
   return self;
}

-(Qvect *)stupidCopy {
   Qvect *copy;
  
   copy = [[Qvect alloc] initWithR:R I:I J:J K:K];
   return copy;
}
/* This, as the name suggests, is a cluge*/

-(Qvect *)makeExpI:(unsigned)n :(unsigned)m {
   float theta;   

   theta = (PI*n)/m;
   [self setReal: cos(theta)];
   [self setI: sin(theta)];
   [self setJ:0.];
   [self setK:0.];
   return self;
}

-(Qvect *)makeExpJ:(unsigned)n :(unsigned)m {
   float theta;   

   theta = (PI*n)/m;
   [self setReal: cos(theta)];
   [self setI:0.0];
   [self setJ: sin(theta)];
   [self setK:0.0];
   return self;
}

-(Qvect *)makeExpK:(unsigned)n :(unsigned)m {
   float theta;   

   theta = (PI*n)/m;
   [self setReal: cos(theta)];
   [self setI:0.0];
   [self setJ:0.0];
   [self setK: sin(theta)];
   return self;
}

-(Qvect *)makeRotatorAxis:(float)x :(float)y :(float)z
                Angle:(unsigned)m :(unsigned)n {
   float theta,sth;   
   Qvect *Rtr;

   theta = (PI*n)/m;
   sth = sin(theta);
   x = sth*x; y = sth*y; z = sth*z;
   Rtr = [[Qvect alloc] initWithR:cos(theta) I:x J:y K:z];
   return Rtr;
}

-(Qvect *)rotateAxis:(float)x :(float)y :(float)z
               Angle:(unsigned)n :(unsigned)m {
    Qvect *Rtr,*answer;

    Rtr = [self makeRotatorAxis:x :y :z Angle:n :m];
    answer = [self conjBy: Rtr];
    [Rtr free];
    return answer;
}

-(AxAng *)makeAa {
    float r,i,j,k,theta;
    AxAng *aa;
    
    r = [self valReal]; i = [self valI];
    j = [self valJ]; k = [self valK];
    theta = acos(r);
    i = i/sin(theta); j = j/sin(theta); k = k/sin(theta);
    aa = [[AxAng alloc] initWithAxisX:i Y:j Z:k Ang:theta];
    return aa;
}

-conj {
   Qvect *conj;

   conj = [[Qvect alloc] initWithR:R I:-I J:-J K:-K];
   return conj;
}

-conjD {
   I = -I; J = -J; K = -K;
   [self setR:R I:I J:J K:K];
   return self;
} 

-sumWith:(Qvect *)otherQv {
    Qvect *sum;
    float r,i,j,k;
    
    r = R + otherQv->R;
    i = I + otherQv->I;
    j = J + otherQv->J;
    k = K + otherQv->K;    
    sum = [[Qvect alloc] initWithR:r I:i J:j K:k];
    return sum;
}

-sumWithD:(Qvect *)otherQv {
    Qvect *sum;
    float r,i,j,k;
    
    r = R + otherQv->R;
    i = I + otherQv->I;
    j = J + otherQv->J;
    k = K + otherQv->K;    
    sum = [otherQv setR:r I:i J:j K:k];
    return sum;
}

-scalarMult:(float)scalar {
    Qvect *scalarmult;
    float r,i,j,k;
    
    r = R * scalar;
    i = I * scalar;
    j = J * scalar;
    k = K * scalar;

    scalarmult = [[Qvect alloc] initWithR:r I:i J:j K:k];    
    return scalarmult;
}

-prodWith:(Qvect *)q {
    Qvect *Qvprod;
    float R2,I2,J2,K2,r,i,j,k;

    R2 = (q->R); I2 = (q->I); J2 = (q->J); K2 = (q->K);    
    
    r = R*R2 - I*I2 - J*J2 - K*K2;
    i = R*I2 + I*R2 + J*K2 - K*J2;
    j = R*J2 - I*K2 + J*R2 + K*I2;
    k = R*K2 + I*J2 - J*I2 + K*R2;
    Qvprod = [[Qvect alloc] initWithR:r I:i J:j K:k];    
    return Qvprod;
}

-prodWithD:(Qvect *)q {
    float R2,I2,J2,K2,r,i,j,k;

    R2 = (q->R); I2 = (q->I); J2 = (q->J); K2 = (q->K);    
    
    r = R*R2 - I*I2 - J*J2 - K*K2;
    i = R*I2 + I*R2 + J*K2 - K*J2;
    j = R*J2 - I*K2 + J*R2 + K*I2;
    k = R*K2 + I*J2 - J*I2 + K*R2;
    [q setR:r I:i J:j K:k];    
    return q;
}

-conjBy: (Qvect *)P {
     Qvect *result;
  
     result = [P prodWithD: [self prodWithD: [P conj]]];
     return result;   
}

-print {
   printf("The value is %f + %f i + %f j + %f k.\n",R,I,J,K);
   return self;
}
    
-printForGVwithName:(char *)name Size:(unsigned)m
            Col:(char *)col {
     float r,i,j,k,epsilon,ce,se,red,green,blue;
     int h;
     Qvect *e[6],*prod;

     sscanf(col," %f %f %f ",&red,&green,&blue);
     epsilon = (PI/m);
     ce = cos(epsilon); se= sin(epsilon);
     for (h=0;h<6;h++) {
       e[h] = [[Qvect alloc] initToZero];
     }
     [e[0] setReal:ce]; [e[0] setK:se];
     [e[1] setReal:ce]; [e[1] setI:se];
     [e[2] setReal:ce]; [e[2] setJ:se];
     [e[3] setReal:ce]; [e[3] setI:-se];
     [e[4] setReal:ce]; [e[4] setJ:-se];
     [e[5] setReal:ce]; [e[5] setK:-se];
            
    fprintf(togv, "(read geometry { define %s \n",name);  
    fprintf(togv,"4OFF\n");
    fprintf(togv,"6 8 12\n");
    for (h=0;h<6;h++) {
      prod = [e[h] prodWith: self];
      r = [prod valReal];
      i = [prod valI];
      j = [prod valJ];
      k = [prod valK];
       fprintf(togv, "%f %f %f %f\n",k,j,i,r);
      [prod free]; [e[h] free]; 
     }
     fprintf(togv, "3 1 0 4 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 4 0 3 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 3 0 2 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 2 0 1 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 1 5 2 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 2 5 3 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 3 5 4 %f %f %f\n",red,green,blue);
     fprintf(togv, "3 4 5 1 %f %f %f\n",red,green,blue);
     fprintf(togv, "}\n");
     fprintf(togv, ")\n");
     fprintf(togv, "(geometry %s {:%s})\n",name,name);
     fflush(togv);
     return self;
}

-doIncrTransinSteps:(int)n to:(Tcl_Channel)toGv {
   int m;
   char rotkey[15], temp[100];
   Qvect *qv;
   float theta,itheta,x,y,z;

   theta = acos(R);
   x = I/sin(theta); y= J/sin(theta); z = K/sin(theta);
   itheta = theta/n;
   qv = [[Qvect alloc] initWithR:cos(itheta) I:(x*sin(itheta))                               J:(y*sin(itheta)) K:(z*sin(itheta))];
   sprintf(rotkey,"rot_%d",n);
   [qv printTransfForChannel:rotkey to:toGv]; 
   for(m=0;m<n;m++) {
      sprintf(temp,"(xform world {:%s})\n",rotkey);
      Tcl_Write(toGv, temp, -1);
   }
   Tcl_Flush(toGv);
   [qv free];
   return self;
}


 /*Computation from Nathaniel Thurston*/
-printTransfForGV:(char *)name to:(FILE *)toGv {
  float i, j, k, r;

  i = [self valI]; j = [self valJ];
  k = [self valK]; r = [self valReal];

  fprintf(toGv,"(read transform {transform define %s ",name);
  fprintf(toGv,"%f ", 1 - 2 * j * j - 2 * k * k);
  fprintf(toGv,"%f ", 2 * i * j + 2 * r * k);
  fprintf(toGv,"%f ", 2 * i * k - 2 * r * j);
  fprintf(toGv,"%f ", 0.0);
  fprintf(toGv,"%f ", 2 * i * j - 2 * r * k);
  fprintf(toGv,"%f ", 1 - 2 * i * i - 2 * k * k);
  fprintf(toGv,"%f ", 2 * j * k + 2 * r * i);
  fprintf(toGv,"%f ", 0.0);
  fprintf(toGv,"%f ", 2 * i * k + 2 * r * j);
  fprintf(toGv,"%f ", 2 * j * k - 2 * r * i);
  fprintf(toGv,"%f ", 1 - 2 * i * i - 2 * j * j);
  fprintf(toGv,"%f ", 0.0);
  fprintf(toGv,"%f ", 0.0);
  fprintf(toGv,"%f ", 0.0);
  fprintf(toGv,"%f ", 0.0);
  fprintf(toGv,"%f ", 1.0);
  fprintf(toGv,"})\n");
  return self;
}

-printTransfForChannel:(char *)name to:(Tcl_Channel)toGv {
  float i, j, k, r;
  char temp[200];

  i = [self valI]; j = [self valJ];
  k = [self valK]; r = [self valReal];

  sprintf(temp,"(read transform {transform define %s ",name);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 1 - 2 * j * j - 2 * k * k);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 2 * i * j + 2 * r * k);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 2 * i * k - 2 * r * j);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 0.0);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 2 * i * j - 2 * r * k);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 1 - 2 * i * i - 2 * k * k);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 2 * j * k + 2 * r * i);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 0.0);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 2 * i * k + 2 * r * j);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 2 * j * k - 2 * r * i);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 1 - 2 * i * i - 2 * j * j);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 0.0);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 0.0);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 0.0);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 0.0);
    Tcl_Write(toGv, temp, -1);
  sprintf(temp,"%f ", 1.0);
    Tcl_Write(toGv, temp, -1);
  Tcl_Write(toGv,"})\n",-1);
  return self;
}


@end



