#import <Foundation/Foundation.h>
#import <Cedar/Cedar.h>

@class HYDError;

class BeAnError : public Cedar::Matchers::Base<> {
public:
    BeAnError() : Base<>(), checkErrorCode(false), expectedDomain(nil), userInfoSubset(nil), checkFatality(false) {}
    ~BeAnError(){}

    bool matches(const HYDError *) const;

    BeAnError with_code(NSInteger code) const;
    BeAnError with_domain(NSString *domain) const;
    BeAnError and_fatal() const;
    BeAnError and_non_fatal() const;

protected:
    virtual NSString * failure_message_end() const;
    bool domain_matches(const HYDError *error) const;
    bool code_matches(const HYDError *error) const;
    bool fatality_matches(const HYDError *error) const;
    bool subset_of_userinfo_matches(const HYDError *error) const;

private:
    BOOL checkFatality;
    BOOL isFatal;
    BOOL checkErrorCode;
    NSInteger expectedErrorCode;
    NSString *expectedDomain;
    NSMutableDictionary *userInfoSubset;
};

OBJC_EXTERN BeAnError be_an_error;
OBJC_EXTERN BeAnError be_a_fatal_error;
OBJC_EXTERN BeAnError be_a_non_fatal_error;
