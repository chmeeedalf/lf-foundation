#import <Foundation/NSTextCheckingResult.h>
#import <Foundation/NSObject.h>
#import <Foundation/GSBlocks.h>
@class NSTextCheckingResult;
@class NSError;
@class NSString, NSMutableString;
@class NSURI;

typedef NSUInteger NSRegularExpressionOptions;
enum {
	NSRegularExpressionUseUnixLineSeparators       = 1<<0,
	NSRegularExpressionCaseInsensitive             = 1<<1,
	NSRegularExpressionAllowCommentsAndWhitespace  = 1<<2,
	NSRegularExpressionAnchorsMatchLines           = 1<<3,
	NSRegularExpressionIgnoreMetacharacters        = 1<<4,
	NSRegularExpressionDotMatchesLineSeparators    = 1<<5,
	NSRegularExpressionUseUnicodeWordBoundaries    = 1<<7,
};

typedef NSUInteger NSMatchingFlags;
enum {
	NSMatchingProgress      = 1<<0,
	NSMatchingCompleted     = 1<<1,
	NSMatchingHitEnd        = 1<<2,
	NSMatchingRequiredEnd   = 1<<3,
	NSMatchingInternalError = 1<<4,
};

typedef NSUInteger NSMatchingOptions;
enum {
	NSMatchingReportProgress         = 1<<0,
	NSMatchingReportCompletion       = 1<<1,
	NSMatchingAnchored               = 1<<2,
	NSMatchingWithTransparentBounds  = 1<<3,
	NSMatchingWithoutAnchoringBounds = 1<<4,
};


DEFINE_BLOCK_TYPE(GSRegexBlock, void, NSTextCheckingResult*, NSMatchingFlags, BOOL*);

#ifndef GSREGEXTYPE
#define GSREGEXTYPE void
#endif

@interface NSRegularExpression : NSObject <NSCoding, NSCopying>
{
	@private
	GSREGEXTYPE *regex;
	NSRegularExpressionOptions options;
}
+ (NSRegularExpression*)regularExpressionWithPattern: (NSString*)aPattern
                                             options: (NSRegularExpressionOptions)opts
                                               error: (NSError**)e;
- initWithPattern: (NSString*)aPattern
          options: (NSRegularExpressionOptions)opts
            error: (NSError**)e;
+ (NSRegularExpression*)regularExpressionWithPattern: (NSString*)aPattern
                                             options: (NSRegularExpressionOptions)opts
                                               error: (NSError**)e;
- initWithPattern: (NSString*)aPattern
          options: (NSRegularExpressionOptions)opts
            error: (NSError**)e;
- (NSString*)pattern;
- (void)enumerateMatchesInString: (NSString*)string
                         options: (NSMatchingOptions)options
                           range: (NSRange)range
                      usingBlock: (GSRegexBlock)block;
- (NSUInteger)numberOfMatchesInString: (NSString*)string
                              options: (NSMatchingOptions)options
                                range: (NSRange)range;

- (NSTextCheckingResult*)firstMatchInString: (NSString*)string
                                    options: (NSMatchingOptions)options
                                      range: (NSRange)range;
- (NSArray*)matchesInString: (NSString*)string
                    options:(NSMatchingOptions)options
                      range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInString: (NSString*)string
                             options: (NSMatchingOptions)options
                               range: (NSRange)range;
- (NSUInteger)replaceMatchesInString: (NSMutableString*)string
                             options: (NSMatchingOptions)options
                               range: (NSRange)range
                        withTemplate: (NSString*)templat;
- (NSString*)stringByReplacingMatchesInString: (NSString*)string
                                      options: (NSMatchingOptions)options
                                        range: (NSRange)range
                                 withTemplate: (NSString*)templat;
- (NSString*)replacementStringForResult: (NSTextCheckingResult*)result
                               inString: (NSString*)string
                                 offset: (NSInteger)offset
                               template: (NSString*)templat;
#if GS_HAS_DECLARED_PROPERTIES
@property (readonly) NSRegularExpressionOptions options;
@property (readonly) NSUInteger numberOfCaptureGroups;
#else
- (NSRegularExpressionOptions)options;
- (NSUInteger)numberOfCaptureGroups;
#endif
@end

@interface NSDataDetector	:	NSRegularExpression
{
}
@property(readonly) NSTextCheckingTypes checkingTypes;
+ dataDetectorWithTypes:(NSTextCheckingTypes)types error:(NSError **)errorp;
- initWithTypes:(NSTextCheckingTypes)types error:(NSError **)errorp;
@end
