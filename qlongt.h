/*   Object for creating OOGL files in spherical space  */
/*    Longitudes of SU2   */
/*    Written by Rebecca Frankel */

#import "qvect.h" 
#import "tcl.h"
#ifdef NeXT
#import <objc/List.h>
#else
#import "List.h"
#endif

@interface Qlongt: List
{
}

/* Initialize */
- initWithSize:(unsigned)n;    /*does not allocate elements*/
- initToZeroWithSize:(unsigned)n; /*allocates elements and sets to zero*/

/* Selector */
-(Qvect *)addQ:(Qvect *)q;
-(Qvect *)getQatVert:(unsigned)index;
-(Qvect *)getQatVertD:(unsigned)index;
-(Qvect *)replaceQatVert:(unsigned)index with:(Qvect *)Q;

/* Free */
- free;

/* Make Object (from an initWithSize'd Qlongt) */
-(Qlongt *) makeDiagLongt;
-(Qlongt *) makeDiagLongtIn:(Tcl_Interp *)interp;
-(Qlongt *) diagConjBy:(Qvect *)qvP;
-(Qlongt *) diagMultBy:(Qvect *)qvP;
-(Qlongt *) makeJLongt;
-(Qlongt *) makeKLongt;
-(Qlongt *) makeJKGrCirc:(float)r;  
-(Qlongt *) makeIJGrCirc:(float)r;
-(Qlongt *) makeIKGrCirc:(float)r;
-(Qlongt *)rotateRhoGC:(unsigned)n :(unsigned)m;

/*  Print  */
- printForGV:(char *) name;
- printForOOGL;
- printForGVwithOther:(Qlongt *)qlongt Name:(char *)name Col:(char *)col;
- printSphereRhoRotations:(char *)name numL:(unsigned)nL Col:(char *)col;
- printForGVwithWidth:(char *)name Col:(char *)col;

@end 



