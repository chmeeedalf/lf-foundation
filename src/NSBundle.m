/* 
   NSBundle.m
 * All rights reserved.

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libSystem.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
 */

#import <Foundation/NSBundle.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSURL.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#import "internal.h"

#define RESOURCES_PATH "/system/lib:/local/lib"

/*
 * Directory structure of a Gold bundle:
 *
 * (NSApplication and Plugin)
 * /
 * -> /exe
 * -> /Info.plist
 * -> /Resources
 *    -> /<localization>.lproj
 *    -> /user_defined
 * -> /PlugIns
 *    -> /PlugIn1
 * -> /Frameworks
 *
 * (Framework)
 * /
 * -> /Current <symlink into Versions>
 * -> /Versions
 *    -> /A
 *       -> /FrameworkName
 *       -> /Headers
 *       -> /Resources
 */

/*
 * Static class variables
 */

#if 0
typedef struct
{
	Class    class;
	Category *category;
} LoadingClassCategory;
#endif

static NSMapTable           *bundleClasses     = NULL; // class -> bundle mapping
static NSMapTable           *bundleNames       = NULL; // path  -> bundle mapping
static NSMapTable           *bundleIdentifiers = NULL;
static NSBundle             *mainBundle        = nil;  // application bundle
//static LoadingClassCategory*	load_Classes      = NULL; // used while loading
static int                  load_classes_size = 0;    // used while loading
static int                  load_classes_used = 0;    // used while loading

NSMakeSymbol(NSBundleIdentifier);
NSMakeSymbol(NSBundleDidLoadNotification);

/*
 * Private API
 */

@interface NSBundle (PrivateAPI)
- (NSURL *)URLForResource:(NSString*)name ofType:(NSString*)ext
  inDirectory:(NSString*)directory
  forLocalizations:(NSArray*)localizationNames;
@end

/*
 * NSBundle methods
 */

@implementation NSBundle

// NSBundle initialization

+ (void)initialize
{
	if (self != [NSBundle class])
		return;

	bundleClasses = [NSMapTable mapTableWithWeakToWeakObjects];
	bundleNames = [NSMapTable mapTableWithStrongToWeakObjects];
	bundleIdentifiers = [NSMapTable mapTableWithStrongToWeakObjects];
}

// Load info for bundle

- (void)loadInfo
{
	NSURL *file;

	if (infoDictionary)
		return;

	file = [self URLForResource:@"Info" ofType:@"plist"];

	if (file)
		infoDictionary = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfURL:file] options:0 format:NULL error:NULL];

	if (infoDictionary == nil)
		infoDictionary = [[NSDictionary alloc] init];
}

#if 0
// Internal code loading
static void load_callback(Class class, Category* category)
{
	if (load_classes_used >= load_classes_size)
	{
		load_classes_size += 128;
		load_Classes = realloc(load_Classes,
				load_classes_size*sizeof(LoadingClassCategory));
	}
	load_Classes[load_classes_used].class    = class;
	load_Classes[load_classes_used].category = category;

	load_classes_used++;
}
#endif

- (bool) isLoaded
{
	return codeLoaded;
}

- (bool)load
{
	return [self loadAndReturnError:NULL];
}

- (bool) loadAndReturnError:(NSError **)err
{
	int            i;
	NSFileManager  *fm;
	NSURL          *file;
	NSURL          *rfile;
	void         *status;
	NSString       *tmp;
	NSMutableArray *loadedClasses    = nil;

	if (codeLoaded)
		return true;

	codeLoaded = true;

	fm = [NSFileManager defaultManager];

	// Find file to load
	file = [self executableURL];

	if (file == nil)
	{
		NSLog(@"has no exe\n");
		tmp = [fullPath lastPathComponent];
		tmp = [tmp stringByDeletingPathExtension];
		file = [fullPath URLByAppendingPathComponent:tmp];
	}

	rfile = [file URLByResolvingSymlinksInPath];
	if (rfile == nil || ![fm fileExistsAtURL:rfile])
	{
		NSLog(@"NSBundle: cannot find executable file %@", file);
		return false;
	}

	loadedClasses = [NSMutableArray arrayWithCapacity:32];

	// Prepare to keep classes/categories loaded
	load_classes_size = 128;
	load_classes_used = 0;
	//load_Classes = malloc(load_classes_size * sizeof(LoadingClassCategory));

	status = dlopen([[file path] fileSystemRepresentation], RTLD_LAZY);

	if (status)
	{
		firstLoadedClass = Nil;

		for (i = 0; i < load_classes_used; i++)
		{
			// get first class from bundle
#if 0
TODO: loader stuff
			if (firstLoadedClass == NULL)
			{
				if (load_Classes[i].category == NULL)
					firstLoadedClass = load_Classes[i].class;
			}

			// insert in bundle hash
			if (load_Classes[i].category == NULL)
				[bundleClasses setObject:self forKey:load_Classes[i].class];

			// register for notification
			if (load_Classes[i].category == NULL)
			{
				NSString *className = nil;

				className = StringFromClass(load_Classes[i].class);
				[loadedClasses addObject:className];
			}
			else
			{
				NSString *className    = nil;

				if (load_Classes[i].class)
				{
					className = StringFromClass(load_Classes[i].class);
				}
				if (className) [loadedClasses addObject:className];
			}
#endif
		}
	}

	//free(load_Classes); load_Classes = NULL;

	if (status)
	{
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:NSBundleDidLoadNotification
						  object:self
						userInfo:@{ @"LoadedClasses": loadedClasses }];
	}
	return status;
}

- (bool) preflightAndReturnError:(NSError **)errp
{
	if ([self isLoaded])
	{
		return true;
	}

	if ([self executableURL] == nil)
	{
		if (errp != NULL)
		{
		}
		return false;
	}

	return true;
}

- (bool) unload
{
	[self notImplemented:_cmd];
	return false;
}

// Initializing an NSBundle 

static bool canReadDirectory(NSURL* path)
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	bool isDirectory;

	if (![fileManager fileExistsAtURL:path isDirectory:&isDirectory]
			|| !isDirectory)
		return false;

	return [fileManager isReadableFileAtURL:path];
}

static bool canReadFile(NSURL *path)
{
	NSFileManager* fileManager = [NSFileManager defaultManager];

	return [fileManager isReadableFileAtURL:path];
}

- (id)initWithURL:(NSURL *)path
{
	NSBundle *old;

	path = [path URLByResolvingSymlinksInPath];
	if ((path == nil) || !canReadDirectory(path))
	{
		return nil;
	}

	old = [bundleNames objectForKey:path];
	if (old)
	{
		(void)self;
		return old;
	}

	[bundleNames setObject:self forKey:path];
	fullPath = path;

	if ([self bundleIdentifier] != nil)
	{
		[bundleIdentifiers setObject:self forKey:[self bundleIdentifier]];
	}
	return self;
}

- (void)dealloc
{
	[bundleNames setObject:nil forKey:fullPath];
}

// Getting an NSBundle 

+ (NSArray *)allBundles
{
	NSMutableArray *bundles = [NSMutableArray arrayWithCapacity:64];

	for (NSBundle *value in [bundleNames objectEnumerator])
		[bundles addObject:value];

	return [bundles copy];
}

+ (NSArray *)allFrameworks
{
	TODO; // +[NSBundle allFrameworks]
	return nil;
}

+ (NSBundle *)bundleForClass:(Class)aClass
{
	NSBundle *bundle;

	if ((bundle = [bundleClasses objectForKey:aClass]))
		return bundle;

	return [self mainBundle];
}

+ (NSBundle *) bundleWithIdentifier:(NSString *)ident
{
	NSBundle *bundle;

	bundle = [bundleIdentifiers objectForKey:ident];
	
	if (bundle != nil)
	{
		return bundle;
	}

	return [self mainBundle];
}

+ (NSBundle *)bundleWithURL:(NSURL *)path
{
	if (path)
	{
		NSBundle *bundle;

		/* look in cache */
		if ((bundle = [bundleNames objectForKey:path]))
			return bundle;
	}
	return [[self alloc] initWithURL:path];
}

+ (NSBundle *)mainBundle
{
	if (mainBundle == nil)
	{
		NSString *path = [[[[NSProcessInfo processInfo] arguments]
			objectAtIndex:0]
			stringByDeletingLastPathComponent];
		if ([path isEqual:@""])
			path = @".";
		mainBundle = [[NSBundle alloc] initWithURL:[NSURL fileURLWithPath:path]];
	}
	return mainBundle;
}

+ (NSArray *) preferredLocalizationsFromArray:(NSArray *)localizationsArray forPreferences:(NSArray *)preferences
{
	NSMutableArray *arr = [NSMutableArray new];

	for (NSString *locale in preferences)
	{
		if ([localizationsArray indexOfObject:locale] != NSNotFound)
		{
			[arr addObject:locale];
		}
	}
	return arr;
}

+ (NSArray *) preferredLocalizationsFromArray:(NSArray *)localizations
{
	return [self preferredLocalizationsFromArray:localizations forPreferences:[[NSUserDefaults standardUserDefaults] arrayForKey:@"Languages"]];
}

// Getting a Bundled Class 

- (Class)classNamed:(NSString *)className
{
	Class class;

	[self load];

	class = NSClassFromString(className);
	if (class != Nil && [NSBundle bundleForClass:class] == self)
		return class;

	return nil;
}

- (Class)principalClass
{
	NSString *className;
	Class    class;

	[self load];

	className = [[self infoDictionary] objectForKey:@"PrincipalClass"];

	if ((class = NSClassFromString(className)) == Nil)
		class = firstLoadedClass;

	if (class)
	{
#ifdef DEBUG
		if ([bundleClasses objectForKey:class] != self)
		{
			NSLog(@"WARNING(%s): principal class %@ of bundle %@ "
					@"is not a class of the bundle !",
					__func__, class, self);
		}
#endif
	}

	return class;
}

// Finding a Resource 

- (NSURL *)URLForResource:(NSString*)name ofType:(NSString*)ext
			   inDirectory:(NSString*)directory
{
	NSArray *languages = [[NSUserDefaults standardUserDefaults] 
		stringArrayForKey:@"Languages"]; 
	return [self URLForResource:name ofType:ext inDirectory:directory
				forLocalizations:languages];
}

- (NSURL *)URLForResource:(NSString*)name ofType:(NSString*)ext
			   inDirectory:(NSString*)directory
		   forLocalization:(NSString*)localizationName
{
	NSArray *languages = nil;

	if(localizationName)
	{
		languages = [NSArray arrayWithObject:localizationName];
	}
	return [self URLForResource:name ofType:ext inDirectory:directory
				forLocalizations:languages];

}

- (NSURL *)URLForResource:(NSString*)name ofType:(NSString*)ext
			   inDirectory:(NSString*)directory
		  forLocalizations:(NSArray*)localizationNames
{
	int i, n;
	NSURL *path;
	NSURL *file;
	NSMutableArray* languages;

	// Translate list by adding "lproj" extension
	// {English, German, ...} to {English.lproj, German.lproj, ...}
	languages = [localizationNames mutableCopy];
	if(languages)
		n = [languages count];
	else
		n = 0;
	for (i = 0; i < n; i++)
	{
		NSString *f = [[languages objectAtIndex:i] 
			   stringByAppendingPathExtension:@"lproj"];
		[languages replaceObjectAtIndex:i withObject:f];
	}

	// make file name name.ext if extension is present
	if (ext)
		name = [name stringByAppendingPathExtension:ext];

	// look for fullPath/Resources/directory/...
	path = [fullPath URLByAppendingPathComponent:@"Resources"];
	if (directory && ![directory isEqualToString:@""])
	{
		path = [path URLByAppendingPathComponent:directory];
	}
	if (canReadDirectory(path))
	{
		// check languages
		for (i = 0; i < n; i++)
		{
			file = [[path URLByAppendingPathComponent:
							 [languages objectAtIndex:i]]
						  URLByAppendingPathComponent:name];
			if (canReadFile(file))
				goto found;
		}
		// check base
		file = [path URLByAppendingPathComponent:name];
		if (canReadFile(file))
			goto found;
	}

	// look for fullPath/directory/...
	if (directory && ![directory isEqualToString:@""])
	{
		path = [fullPath URLByAppendingPathComponent:directory];
	}
	else
		path = fullPath;
	if (canReadDirectory(path))
	{
		// check languages
		for (i = 0; i < n; i++)
		{
			file = [[path URLByAppendingPathComponent:
							 [languages objectAtIndex:i]]
						  URLByAppendingPathComponent:name];
			if (canReadFile(file))
				goto found;
		}
		// check base
		file = [path URLByAppendingPathComponent:name];
		if (canReadFile(file))
			goto found;
	}

	file = nil;

found:

	return file;
}

- (NSArray *)URLsForResourcesOfType:(NSString *)extension
					   inDirectory:(NSString *)bundlePath
{
	return [self URLsForResourcesOfType:extension inDirectory:bundlePath
						 forLocalization:nil];
}

- (NSArray *)URLsForResourcesOfType:(NSString *)extension
					   inDirectory:(NSString *)bundlePath
				   forLocalization:(NSString *)localizationName
{
	NSFileManager  *fm;
	NSMutableArray *result = nil;
	NSURL       *path, *mainPath;

	fm     = [NSFileManager defaultManager];
	result = [[NSMutableArray alloc] initWithCapacity:32];

	/* look in bundle/Resources/$bundlePath/name.$extension */
	mainPath = [self resourceURL];
	if (bundlePath)
		mainPath = [mainPath URLByAppendingPathComponent:bundlePath];

	for (path in [fm contentsOfDirectoryAtURL:mainPath error:NULL])
	{
		if ([[path pathExtension] isEqualToString:extension])
								[result addObject:path];
	}

#if 0 // to be completed
	/* look in bundle/Resources/$bundlePath/$Language.lproj/name.$extension */
	mainPath = [self resourcePath];
	if (bundlePath)
	{
		mainPath = [mainPath stringByAppendingPathComponent:bundlePath];
	}
	for (path in [fm contentsOfDirectoryAtURL:mainPath error:NULL])
	{
		if ([[path pathExtension] isEqualToString:extension])
								[result addObject:path];
	}
#endif

	/* look in bundle/$bundlePath/name.$extension */
	mainPath = fullPath;
	if (bundlePath)
		mainPath = [mainPath URLByAppendingPathComponent:bundlePath];

	for (path in [fm contentsOfDirectoryAtURL:mainPath error:NULL])
	{
		if ([[path pathExtension] isEqualToString:extension])
								[result addObject:path];
	}
	NSArray *tmp;
	tmp = [result copy];
	return tmp;
}

+ (NSArray *) URLsForResourcesOfType:(NSString *)ext subdirectory:(NSString *)subdir inBundleWithURL:(NSURL *)bundleURL
{
	return [[self bundleWithURL:bundleURL] URLsForResourcesOfType:ext inDirectory:subdir];
}

+ (NSURL *) URLForResource:(NSString *)rsrcName ofType:(NSString *)ext subdirectory:(NSString *)subdir inBundleWithURL:(NSURL *)bundleURL
{
	return [[self bundleWithURL:bundleURL] URLForResource:rsrcName ofType:ext inDirectory:subdir];
}

- (NSURL *)URLForResource:(NSString*)name ofType:(NSString*)ext
{
	return [self URLForResource:name ofType:ext inDirectory:nil];
}

- (NSURL *)resourceURL
{
	return [fullPath URLByAppendingPathComponent:@"Resources"];
}

// Getting bundle information

- (NSDictionary*)infoDictionary
{
	[self loadInfo];
	return infoDictionary;
}

- (NSDictionary *) localizedInfoDictionary
{
	return [self infoDictionary];
}

// Getting the NSBundle Directory 

- (NSURL *)bundleURL
{
	return fullPath;
}

- (NSString *) bundleIdentifier
{
	return [[self infoDictionary] objectForKey:NSBundleIdentifier];
}

- (id) objectForInfoDictionaryKey:(NSString *)key
{
	return [[self infoDictionary] objectForKey:key];
}

// Managing Localized Resources

- (NSString*)localizedStringForKey:(NSString*)key value:(NSString*)value
						   table:(NSString*)tableName
{
	TODO; //-[NSBundle localizedStringForKey:value:table:]
	return nil;
#if 0
	NSDictionary* table;
	NSString* string;

	if (!stringTables)
		stringTables = [NSMutableDictionary new];

	table = [stringTables objectForKey:tableName];
	if (value == nil)
		value = key;

	if (!table)
	{
		string = [NSString stringWithContentsOfURL:
							[self URLForResource:tableName ofType:@"strings"] usedEncoding:NULL error:NULL];
		if (!string)
			return value;
		table = [string propertyListFromStringsFileFormat];
		if (table)
			[stringTables setObject:table forKey:tableName];
	}

	string = [table objectForKey:key];
	if (!string)
		string = value;

	return string;
#endif
}

- (NSString *)description
{
	/* Don't use -[NSString stringWithFormat:] method because it can cause
	   infinite recursion. */
	char buffer[1024];

	sprintf (buffer,
			"<%s %p fullPath: %s infoDictionary: %p loaded=%s>",
			(char*)object_getClassName(self),
			self,
			[[fullPath description] cStringUsingEncoding:NSUTF8StringEncoding],
					 infoDictionary, codeLoaded ? "yes" : "no");

	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

- (NSURL *) executableURL
{
	NSString *exeName = [[self infoDictionary] objectForKey:@"Executable"];

	if (exeName == nil)
	{
		return nil;
	}

	return [[self bundleURL] URLByAppendingPathComponent:exeName];
}

- (NSURL *) URLForAuxiliaryExecutable:(NSString *)auxExeName
{
	if (auxExeName == nil)
	{
		return nil;
	}

	return [[self bundleURL] URLByAppendingPathComponent:auxExeName];
}

- (NSURL *) _directoryURLForName:(NSString *)name
{
	bool isDir;

	NSURL *uri = [[self bundleURL] URLByAppendingPathComponent:name];

	if ([[NSFileManager defaultManager] fileExistsAtURL:uri isDirectory:&isDir] && isDir)
	{
		return uri;
	}
	return nil;
}

- (NSURL *) builtInPlugInsURL
{
	return [self _directoryURLForName:@"PlugIns"];
}

- (NSURL *) privateFrameworksURL
{
	return [self _directoryURLForName:@"Frameworks"];
}

- (NSArray *) localizations
{
	NSArray *localeURLs;
	NSMutableArray *localizations = [NSMutableArray new];

	localeURLs = [self URLsForResourcesOfType:@"lproj" inDirectory:nil];

	for (NSURL *path in localeURLs)
	{
		[localizations addObject:[[[path path] lastPathComponent] stringByDeletingPathExtension]];
	}

	return localizations;
}

- (NSArray *) preferredLocalizations
{
	return [NSBundle preferredLocalizationsFromArray:[self localizations]];
}

@end /* NSBundle */

NSString *NSLocalizedString(NSString *key,NSString *comment)
{
	return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:nil];
}

NSString *NSLocalizedStringFromTable(NSString *key,NSString *table,NSString *comment)
{
	return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:table];
}

NSString *NSLocalizedStringFromTableInBundle(NSString *key,NSString *table,NSBundle *bundle,NSString *comment)
{
	return [bundle localizedStringForKey:key value:nil table:table];
}

/*
   Local Variables:
	c-basic-offset: 4
		 tab-width: 8
			   End:
			   */
