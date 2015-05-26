#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDNumberToStringMapperSpec)

describe(@"HYDNumberToStringMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = @(1235555);
        NSString *numberString = [formatter stringFromNumber:number];

        mapper = HYDMapDecimalNumberToString();
        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = number;
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = [NSDate date];
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = numberString;
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
