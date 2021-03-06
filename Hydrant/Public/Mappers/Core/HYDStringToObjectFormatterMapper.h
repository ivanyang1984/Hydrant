#import "HYDBase.h"
#import "HYDMapper.h"


/*! Constructs a mapper that utilizes the NSFormatter to convert a string into the destination object.
 *
 *  @param formatter the NSFormatter to use for converting the source object into a string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(1);

/*! Constructs a mapper that utilizes the NSFormatter to convert a string into the destination object.
 *
 *  @param innerMapper The mapper that processes the source value before this mapper.
 *  @param formatter the NSFormatter to use for converting the source object into a string.
 */
HYD_EXTERN_OVERLOADED
id<HYDMapper> HYDMapStringToObjectByFormatter(id<HYDMapper> innerMapper, NSFormatter *formatter)
HYD_REQUIRE_NON_NIL(2);
