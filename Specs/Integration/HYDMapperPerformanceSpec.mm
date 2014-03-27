// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import <objc/runtime.h>
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

NSArray *numberOfObjects(NSInteger times, id object) {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:times];
    for (NSInteger i=0; i<times; i++) {
        [items addObject:object];
    }
    return items;
}

// This captures all object allocations that fix a particular class prefix
NSUInteger numberOfAllocationsOf(const char *classPrefix, void(^block)()) {
    __block NSUInteger allocationCount = 0;
    __block BOOL capturing = NO;
    size_t classPrefixLength = strlen(classPrefix);
    Method originalMethod = class_getClassMethod([NSObject class], @selector(alloc));
    IMP originalImpl = method_getImplementation(originalMethod);
    Class metaClass = object_getClass([NSObject class]);
    IMP replacementImpl = imp_implementationWithBlock(^id(id that, SEL cmd){
        if (capturing && strncmp(classPrefix, object_getClassName(that), classPrefixLength) == 0) {
            ++allocationCount;
        }
        id (*allocPtr)(id, SEL) = (id (*)(id, SEL))originalImpl;
        return (*allocPtr)(that, cmd);
    });
    class_replaceMethod(metaClass, @selector(alloc), replacementImpl, method_getTypeEncoding(originalMethod));
    @try {
        capturing = YES;
        block();
    }
    @finally {
        capturing = NO;
        class_replaceMethod(metaClass, @selector(alloc), originalImpl, method_getTypeEncoding(originalMethod));
    }
    return allocationCount;
}

SPEC_BEGIN(HYDMapperPerformanceSpec)

describe(@"HYDMapperPerformance", ^{
    __block NSDictionary *invalidObject;

    beforeEach(^{
        invalidObject = @{@"id": @1,
                          @"name": @{@"first": [NSNull null],
                                     @"last": [NSNull null]},
                          @"siblings": @[@"John", @"Doe"],
                          @"birthDate": @"Not A Real Date",
                          @"gender": @"haha",
                          @"age": @"lulzwut"};
    });

    context(@"parsing an object that generates a fatal error", ^{
        __block id<HYDMapper> mapper;

        beforeEach(^{
            mapper = HYDMapArrayOfObjects([HYDSPerson class],
                                          @{@"name.first": @"firstName",
                                            @"name.last": @"lastName",
                                            @"age": @[HYDMapNumberToString(NSNumberFormatterDecimalStyle), @"age"],
                                            @"siblings": @"siblings",
                                            @"id": @"identifier",
                                            @"birthDate": @[HYDMapDateToString(HYDDateFormatRFC3339_milliseconds), @"birthDate"],
                                            @"gender": @[HYDMapEnum(@{@"male": @(HYDSPersonGenderMale),
                                                                      @"female": @(HYDSPersonGenderFemale)}),
                                                         @"gender"]});
        });

        // This example exists to avoid a large number of string allocations because HYDError tend to use +[NSString stringWithFormat:]
        // that caused significant performance regressions.
        it(@"should not have a large number of allocations of strings", ^{
            NSArray *sourceObject = numberOfObjects(1000, invalidObject);
            numberOfAllocationsOf("NSString", ^{
                HYDError *error = nil;
                [mapper objectFromSourceObject:sourceObject error:&error];
                [error description];
            }) should be_less_than(sourceObject.count);
        });
    });

    context(@"parsing an object that generates supressed errors", ^{
        __block id<HYDMapper> mapper;

        beforeEach(^{
            mapper = HYDMapArrayOfObjects([HYDSPerson class],
                                          @{@"name.first": @[HYDMapOptionally(), @"firstName"],
                                            @"name.last": @[HYDMapOptionally(), @"lastName"],
                                            @"age": @[HYDMapOptionallyTo(HYDMapNumberToString(NSNumberFormatterDecimalStyle)), @"age"],
                                            @"siblings": @[HYDMapOptionally(), @"siblings"],
                                            @"id": @"identifier",
                                            @"birthDate": @[HYDMapOptionallyTo(HYDMapDateToString(HYDDateFormatRFC3339_milliseconds)), @"birthDate"],
                                            @"gender": @[HYDMapOptionallyWithDefault(HYDMapEnum(@{@"male": @(HYDSPersonGenderMale),
                                                                                                  @"female": @(HYDSPersonGenderFemale)}),
                                                                                     @(HYDSPersonGenderUnknown)),
                                                         @"gender"]});
        });

        // This example exists to avoid a large number of string allocations because HYDError tend to use +[NSString stringWithFormat:]
        // that caused significant performance regressions.
        it(@"should not have a large number of allocations of strings", ^{
            NSArray *sourceObject = numberOfObjects(1000, invalidObject);
            numberOfAllocationsOf("NSString", ^{
                HYDError *error = nil;
                [mapper objectFromSourceObject:sourceObject error:&error];
            }) should equal(0);
        });
    });
});

SPEC_END
