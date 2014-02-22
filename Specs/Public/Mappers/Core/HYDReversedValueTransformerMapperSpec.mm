// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSIrreversableValueTransformer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDReversedValueTransformerMapperSpec)

describe(@"HYDReversedValueTransformer", ^{
    __block HYDReversedValueTransformerMapper *mapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    context(@"when using a value transformer via name", ^{
        beforeEach(^{
            mapper = HYDMapReverseValue(@"destinationAccessor", NSNegateBooleanTransformerName);
        });

        it(@"should preserve the destination it was given", ^{
            [mapper destinationAccessor] should equal(HYDAccessDefault(@"destinationAccessor"));
        });

        describe(@"parsing an object", ^{
            beforeEach(^{
                sourceObject = @YES;
                parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            });

            it(@"should transform the value it was given", ^{
                parsedObject should equal(@NO);
            });

            it(@"should never error", ^{
                error should be_nil;
            });
        });

        describe(@"reverse mapper", ^{
            __block id<HYDMapper> reverseMapper;

            beforeEach(^{
                reverseMapper = [mapper reverseMapperWithDestinationAccessor:HYDAccessKey(@"otherKey")];
            });

            it(@"should corrected configure the destination key", ^{
                [reverseMapper destinationAccessor] should equal(HYDAccessKey(@"otherKey"));
            });

            it(@"should be the inverse of the original mapper", ^{
                sourceObject = @YES;
                id result = [mapper objectFromSourceObject:sourceObject error:&error];
                error should be_nil;

                id finalObject = [reverseMapper objectFromSourceObject:result error:&error];
                error should be_nil;
                finalObject should equal(sourceObject);
            });
        });
    });

    context(@"when trying to use a missing value transformer via name", ^{
        it(@"should raise an exception", ^{
            ^{
                mapper = HYDMapReverseValue(@"destinationAccessor", @"invalidTransformer");
            } should raise_exception.with_name(NSInvalidArgumentException);
        });
    });

    context(@"when trying to use an irreversable value transformer", ^{
        it(@"should raise an exception", ^{
            ^{
                mapper = HYDMapReverseValue(@"key", [[HYDSIrreversableValueTransformer alloc] init]);
            } should raise_exception;
        });
    });
});

SPEC_END
