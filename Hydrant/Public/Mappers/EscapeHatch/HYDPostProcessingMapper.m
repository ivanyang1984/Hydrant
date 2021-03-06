#import "HYDPostProcessingMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDError.h"
#import "HYDFunctions.h"



@interface HYDPostProcessingMapper : NSObject <HYDMapper>

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) HYDPostProcessingBlock block;
@property (strong, nonatomic) HYDPostProcessingBlock reverseBlock;

- (id)initWithMapper:(id<HYDMapper>)innerMapper
        processBlock:(HYDPostProcessingBlock)block reverseProcessBlock:(HYDPostProcessingBlock)reverseBlock;

@end


@implementation HYDPostProcessingMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithMapper:(id<HYDMapper>)innerMapper
        processBlock:(HYDPostProcessingBlock)block reverseProcessBlock:(HYDPostProcessingBlock)reverseBlock
{
    self = [super init];
    if (self) {
        self.innerMapper = innerMapper;
        self.block = [block copy];
        self.reverseBlock = [reverseBlock copy];
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>", NSStringFromClass(self.class)];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    HYDError *innerError = nil;
    id resultingObject = [self.innerMapper objectFromSourceObject:sourceObject error:&innerError];
    self.block(sourceObject, resultingObject, &innerError);

    HYDSetObjectPointer(error, innerError);
    if ([innerError isFatal]) {
        return nil;
    }
    return resultingObject;
}

- (id<HYDMapper>)reverseMapper
{
    id<HYDMapper> reversedInnerMapper = [self.innerMapper reverseMapper];
    return [[[self class] alloc] initWithMapper:reversedInnerMapper
                                   processBlock:self.reverseBlock
                            reverseProcessBlock:self.block];
}

@end


HYD_EXTERN_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block, HYDPostProcessingBlock reverseBlock)
{
    return [[HYDPostProcessingMapper alloc] initWithMapper:mapper processBlock:block reverseProcessBlock:reverseBlock];
}


HYD_EXTERN_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(id<HYDMapper> mapper, HYDPostProcessingBlock block)
{
    return HYDMapWithPostProcessing(mapper, block, block);
}


HYD_EXTERN_OVERLOADED
HYDPostProcessingMapper *HYDMapWithPostProcessing(HYDPostProcessingBlock block)
{
    return HYDMapWithPostProcessing(HYDMapIdentity(), block);
}
