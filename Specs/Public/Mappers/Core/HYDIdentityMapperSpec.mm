#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDIdentityMapperSpec)

describe(@"HYDIdentityMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDError *error;
    __block id parsedObject;

    beforeEach(^{
        mapper = HYDMapIdentity();
    });

    describe(@"parsing an object", ^{
        beforeEach(^{
            parsedObject = [mapper objectFromSourceObject:@1 error:&error];
        });

        it(@"should never produce an error", ^{
            error should be_nil;
        });

        it(@"should return the same value it was given", ^{
            parsedObject should equal(@1);
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [CDRSpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @1;
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
