/*   Hash Table for Group Elements */
/*   Written by Rebecca Frankel    */
#define togv stdout
#import <objc/Object.h>
#import <tcl.h>
@class Qvect;
@class Qlongt;

@interface Group: Object {   
   Tcl_HashTable Table;
   Tcl_Interp *Interp;
 }

/*Init (with and without interpreter)*/
-init;
-initIn:(Tcl_Interp *)interp Name:(char *)name;

/*Selectors*/
-(Qvect *)findQforKey:(char *)key;
-removeQforKey:(char *)key;
-insertQ:(Qvect *)qv Key:(char *)key;
-replaceQatKey:(char *)key with:(Qvect *)qv;
-(Tcl_HashTable)getTable;

/*Operations*/
-makeGroupFromFile:(char *)filename;
-(int)listGrp;
-(char *)nearestPoint:(Qvect *)qv;
-(char *)matchPoint:(Qvect *)qv;
 /*(matchPoint assumes a closer match than nearestPoint)*/

/*Free*/
-free;

/*Print*/
-print;
-printForGVasPointswithCol:(char *)col;
-printForGVwithSize:(unsigned)m Col:(char *)col; 
-printForEuclGV:(FILE *)toGv;

@end 







