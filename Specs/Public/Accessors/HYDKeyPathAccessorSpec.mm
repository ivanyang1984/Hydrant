#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDKeyPathAccessorSpec)

describe(@"HYDKeyPathAccessor", ^{
    __block HYDKeyPathAccessor *accessor;

    beforeEach(^{
        accessor = HYDAccessKeyPath(@"parent.firstName");
    });

    describe(@"equality", ^{
        context(@"when the fields all match", ^{
            it(@"should be equal", ^{
                accessor should equal(HYDAccessKeyPath(@"parent.firstName"));
                HYDAccessKeyPath(@"a.b", @"c.d") should equal(HYDAccessKeyPath(@"a.b", @"c.d"));
            });
        });

        context(@"when the fields don't match", ^{
            it(@"should not be equal", ^{
                accessor should_not equal(HYDAccessKeyPath(@"food.cakes"));
            });
        });
    });

    context(@"with multiple keys", ^{
        beforeEach(^{
            accessor = HYDAccessKeyPath(@"parent.firstName", @"parent.lastName");

            [SpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [SpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [HYDSPerson new]; };
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = ({
                HYDSPerson *child = [[HYDSPerson alloc] init];
                child.parent = [[HYDSPerson alloc] init];
                child.parent.firstName = @"John";
                child.parent.lastName = @"Doe";
                child;
            });
            [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @{@"parent": @{@"firstName": @"John"}};
            [SpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"parent.firstName", @"parent.lastName"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"John", @"Doe"];
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] = @{@"parent": @{@"firstName": [NSNull null], @"lastName": @"Doe"}};
            [SpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null], @"Doe"];
        });

        itShouldBehaveLike(@"an accessor");
    });

    context(@"with one key", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"accessor"] = accessor;
            [SpecHelper specHelper].sharedExampleContext[@"createTargetObject"] = ^{ return [HYDSPerson new]; };
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = ({
                HYDSPerson *child = [[HYDSPerson alloc] init];
                child.parent = [[HYDSPerson alloc] init];
                child.parent.firstName = @"John";
                child;
            });
            [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @{};
            [SpecHelper specHelper].sharedExampleContext[@"expectedFieldNames"] = @[@"parent.firstName"];
            [SpecHelper specHelper].sharedExampleContext[@"expectedValues"] = @[@"John"];
            [SpecHelper specHelper].sharedExampleContext[@"validSourceObjectWithNulls"] = @{@"parent": @{@"firstName": [NSNull null]}};
            [SpecHelper specHelper].sharedExampleContext[@"expectedValuesWithNulls"] = @[[NSNull null]];
        });

        itShouldBehaveLike(@"an accessor");
    });
});

SPEC_END
