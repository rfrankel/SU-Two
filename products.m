#import "qvect.h"
#import <stdio.h>

#define togv stdout

void normalize(Qvect *qv);
void delete();

void main() {
  Qvect *e[10];
  int i;

  e[0] = [[Qvect alloc] initWithR:1 I:-4 J:-6 K:2];
  e[1] = [[Qvect alloc] initWithR:1 I:2 J:3 K:4];
  e[2] = [[Qvect alloc] initWithR:1 I:1 J:1 K:1];
  e[3] = [[Qvect alloc] initWithR:-1 I:3 J:-2 K:6];
  e[4] = [[Qvect alloc] initWithR:-1 I:-1 J:-1 K:-1];
  e[5] = [[Qvect alloc] initWithR:2 I:-3 J:-2 K:6];
  e[7] = [[Qvect alloc] initWithR:-11 I:3 J:1 K:1];
  e[8] = [[Qvect alloc] initWithR:7 I:3 J:1 K:3];
 
//  for(i=0;i<6;i++) {
//    normalize(e[10]); 
//    }
 [e[0] print];
  [e[1] print];
  e[9] = [e[0] conjBy: e[1]];
  e[6] = [e[0] prodWith: e[1]];
  [e[6] print];
  [e[9] print];
 fflush(togv);
  sleep(2);
//  delete();

  [e[2] print];
  [e[3] print];
  e[6] = [e[2] conjBy: e[3]];
  e[9] = [e[2] prodWith: e[3]];
  [e[6] print];
  [e[9] print];
  fflush(togv);
  sleep(2);

  [e[0] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
  [e[1] printForGVwithName:"rand2" Size:20 Color:20 :99 :50];
  e[6] = [e[0] prodWith: e[1]];
  [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200];
  fflush(togv);
  sleep(2);
  delete();

  [e[2] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
  [e[3] printForGVwithName:"rand2" Size:20 Color:20 :99 :50];
  e[6] = [e[2] prodWith: e[3]];
  [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200]; 
  fflush(togv);
  sleep(2);
  delete();

  [e[3] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
//  sleep(1);
  [e[2] printForGVwithName:"rand2" Size:20 Color:99 :99 :50];
//  sleep(4);
  e[6] = [e[3] prodWith: e[2]];
 [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200]; 
  sleep(2);
  delete();

  [e[4] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
//  sleep(1);
  [e[5] printForGVwithName:"rand2" Size:20 Color:99 :99 :50];
//  sleep(4);
  e[6] = [e[4] prodWith: e[5]];
 [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200]; 
  fflush(togv);
  sleep(2);
  delete();

  [e[5] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
//  sleep(1);
  [e[4] printForGVwithName:"rand2" Size:20 Color:99 :99 :50];
//  sleep(4);
  e[6] = [e[5] prodWith: e[4]];
 [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200]; 
  fflush(togv);
  sleep(2);
  delete();

  [e[0] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
  [e[7] printForGVwithName:"rand2" Size:20 Color:20 :99 :50];
  e[6] = [e[0] prodWith: e[7]];
  [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200];
  fflush(togv);
  sleep(2);
  delete();

  [e[7] printForGVwithName:"rand1" Size:20 Color:20 :99 :20];
  [e[0] printForGVwithName:"rand2" Size:20 Color:20 :99 :50];
  e[6] = [e[7] prodWith: e[7]];
  [e[6] printForGVwithName:"product" Size:20 Color:50 :99 :200];
  fflush(togv);
  sleep(2);
  delete();
}


void normalize(Qvect *qv) {
   float r,i,j,k,sumsqs;

   r = [qv valReal]; 
   i = [qv valI];
   j = [qv valJ];
   k = [qv valK];

   sumsqs = r*r + i*i + j*j + k*k;
   [qv setReal:(r/sumsqs)];
   [qv setI:(i/sumsqs)];
   [qv setJ:(j/sumsqs)];
   [qv setK:(k/sumsqs)];
}

void delete() {
   fprintf(togv,"(progn ");
   fprintf(togv,"(delete rand1)");
   fprintf(togv,"(delete rand2)");
   fprintf(togv,"(delete product))");
}




