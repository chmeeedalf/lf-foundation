/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/NSObject.h>

@class NSArray,NSDictionary,NSString,NSError,NSMutableDictionary, NSURL;

SYSTEM_EXPORT NSString * const NSBundleDidLoadNotification;
SYSTEM_EXPORT NSString * const NSLoadedClasses;	

@interface NSBundle : NSObject
{
	NSURL        *_path;
	NSURL        *_resourceURL;
	NSURL        *_executableURL;
	NSArray      *_lookInDirectories;
	NSURL            *fullPath;
	NSDictionary        *infoDictionary;
	Class               firstLoadedClass;
	NSMutableDictionary *stringTables;
	bool                codeLoaded;
}

+(NSArray *)allBundles;
+(NSArray *)allFrameworks;

+(NSBundle *)mainBundle;

+(NSBundle *)bundleForClass:(Class)aClass;
+(NSBundle *)bundleWithIdentifier:(NSString *)identifier;
+(NSBundle *)bundleWithURL:(NSURL *)path;

+(NSURL *)URLForResource:(NSString *)name ofType:(NSString *)type subdirectory:(NSString *)subdir inBundleWithURL:(NSURL *)path;
+(NSArray *)URLsForResourcesOfType:(NSString *)type subdirectory:(NSString *)subdir inBundleWithURL:(NSURL *)path;
+(NSArray *)preferredLocalizationsFromArray:(NSArray *)localizations;
+(NSArray *)preferredLocalizationsFromArray:(NSArray *)localizations forPreferences:(NSArray *)preferences;

-(id)initWithURL:(NSURL *)path;

-(NSURL *)bundleURL;
-(NSURL *)resourceURL;
-(NSURL *)builtInPlugInsURL;
-(NSDictionary *)infoDictionary;
-(NSDictionary *)localizedInfoDictionary;
-(id)objectForInfoDictionaryKey:(NSString *)key;
-(NSString *)bundleIdentifier;
-(NSURL *)executableURL;
-(NSArray *)localizations;
-(NSArray *)preferredLocalizations;
-(NSURL *)privateFrameworksURL;

-(NSURL *)URLForAuxiliaryExecutable:(NSString *)executable;

-(Class)principalClass;
-(Class)classNamed:(NSString *)className;

-(bool)isLoaded;
-(bool)preflightAndReturnError:(NSError **)error;
-(bool)loadAndReturnError:(NSError **)error;

-(bool)load;
-(bool)unload;

-(NSURL *)URLForResource:(NSString *)name ofType:(NSString *)type;
-(NSURL *)URLForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)path;
-(NSURL *)URLForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)path forLocalization:(NSString *)localization;

-(NSArray *)URLsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path;
-(NSArray *)URLsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path forLocalization:(NSString *)localization;

-(NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table;

@end

SYSTEM_EXPORT NSString *NSLocalizedString(NSString *key,NSString *comment);
SYSTEM_EXPORT NSString *NSLocalizedStringFromTable(NSString *key,NSString *table,NSString *comment);
SYSTEM_EXPORT NSString *NSLocalizedStringFromTableInBundle(NSString *key,NSString *table,NSBundle *bundle,NSString *comment);
