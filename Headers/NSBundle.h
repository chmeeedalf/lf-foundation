/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>

@class NSArray,NSDictionary,NSString,NSError,NSMutableDictionary, NSURI;

SYSTEM_EXPORT NSString * const NSBundleDidLoadNotification;
SYSTEM_EXPORT NSString * const NSLoadedClasses;	

@interface NSBundle : NSObject
{
	NSURI        *_path;
	NSURI        *_resourceURI;
	NSURI        *_executableURI;
	NSArray      *_lookInDirectories;
	NSURI            *fullPath;
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
+(NSBundle *)bundleWithURI:(NSURI *)path;

+(NSURI *)URIForResource:(NSString *)name ofType:(NSString *)type subdirectory:(NSString *)subdir inBundleWithURI:(NSURI *)path;
+(NSArray *)URIsForResourcesOfType:(NSString *)type subdirectory:(NSString *)subdir inBundleWithURI:(NSURI *)path;
+(NSArray *)preferredLocalizationsFromArray:(NSArray *)localizations;
+(NSArray *)preferredLocalizationsFromArray:(NSArray *)localizations forPreferences:(NSArray *)preferences;

-initWithURI:(NSURI *)path;

-(NSURI *)bundleURI;
-(NSURI *)resourceURI;
-(NSURI *)builtInPlugInsURI;
-(NSDictionary *)infoDictionary;
-(NSDictionary *)localizedInfoDictionary;
-objectForInfoDictionaryKey:(NSString *)key;
-(NSString *)bundleIdentifier;
-(NSURI *)executableURI;
-(NSArray *)localizations;
-(NSArray *)preferredLocalizations;
-(NSURI *)privateFrameworksURI;

-(NSURI *)URIForAuxiliaryExecutable:(NSString *)executable;

-(Class)principalClass;
-(Class)classNamed:(NSString *)className;

-(bool)isLoaded;
-(bool)preflightAndReturnError:(NSError **)error;
-(bool)loadAndReturnError:(NSError **)error;

-(bool)load;
-(bool)unload;

-(NSURI *)URIForResource:(NSString *)name ofType:(NSString *)type;
-(NSURI *)URIForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)path;
-(NSURI *)URIForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)path forLocalization:(NSString *)localization;

-(NSArray *)URIsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path;
-(NSArray *)URIsForResourcesOfType:(NSString *)type inDirectory:(NSString *)path forLocalization:(NSString *)localization;

-(NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table;

@end

SYSTEM_EXPORT NSString *LocalizedString(NSString *key,NSString *comment);
SYSTEM_EXPORT NSString *LocalizedStringFromTable(NSString *key,NSString *table,NSString *comment);
SYSTEM_EXPORT NSString *LocalizedStringFromTableInBundle(NSString *key,NSString *table,NSBundle *bundle,NSString *comment);
