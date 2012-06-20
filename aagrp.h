/*   Hash Table for Group Elements */
/*   Written by Rebecca Frankel    */
#define togv stdout
#import <objc/Object.h>
#import <tcl.h>
@class AxAng;
@class Qvect;
@class Qlongt;
@class Group;

@interface AaGrp: Object {   
   Tcl_HashTable Table;
   Tcl_Interp *Interp;
 }

/*Init (with and without interpreter)*/
-init;
-initIn:(Tcl_Interp *)interp Name:(char *)name;

/*Selectors*/
-(AxAng *)findAaForKey:(char *)key;
-removeAaForKey:(char *)key;
-insertAA:(AxAng *)qv Key:(char *)key;
-replaceAAatKey:(char *)key with:(AxAng *)qv;

/*Operations*/
-initToCyclicOfOrder:(int)n;
-initToDihedralOfOrder:(int)n;
-(char *)makeAaGrpFromOff:(char *)filename;

/*Free*/
-free;

/*Print*/
-print;
-printForEuclGV:(Tcl_Channel)toGv;

/*Convert to Qvect Group */
-convertAaGrpTo:(Group *)QGrp;

@end 







