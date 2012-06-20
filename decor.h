/*   Hash Table for Colors */
/*   Written by Rebecca Frankel    */
#define togv stdout
#import <objc/Object.h>
#import <tcl.h>
@class Color;

@interface Decor: Object {   
   Tcl_HashTable Table;
   Tcl_Interp *Interp;
 }

/*Init (with and without interpreter)*/
-init;
-initIn:(Tcl_Interp *)interp Name:(char *)name;

/*Selectors*/
-(App *)initEntry:(char *)key; 
-(App *)findAforKey:(char *)key;
-(char *)findFaceRGBforKey:(char *)key;
-(char *)findEdgeRGBforKey:(char *)key;
-removeAforKey:(char *)key;
-insertA:(App *)col Key:(char *)key;
-replaceAatKey:(char *)key with:(App *)app;
-(int)listKeys;

/*Operations*/
-makeDecorFromFile:(char *)filename;


/*Free*/
-free;

/*Print*/
-print:(FILE *)file;
-printTclForGv;
-printForGv;
-printForEuclGv:(FILE *)toGv;

@end 
