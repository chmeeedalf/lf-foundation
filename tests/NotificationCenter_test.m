#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
#import <Test/NSTest.h>

@interface TestNotificationCenterClass : NSTest
@end

@interface TestNotificationCenter : NSTest
{
	int noteCounter;
	NSNotificationCenter *noteCenter;
}
- (void) handleNotification:(NSNotification *)n;
@end

@implementation TestNotificationCenterClass
- (void) test_defaultCenter
{
	fail_unless([[[NSNotificationCenter defaultCenter] class] isKindOfClass:[NSNotificationCenter class]],
		@"");
}
@end

static NSString *TestNotification = @"TestNotification";

@implementation TestNotificationCenter
- init
{
	noteCounter = 0;
	noteCenter = [NSNotificationCenter new];
	return self;
}

- (void) dealloc
{
	[noteCenter release];
	[super dealloc];
}

- (void) test_addObserver_selector_name_object_
{
	[noteCenter addObserver:self selector:@selector(handleNotification:) name:TestNotification object:nil];
	[noteCenter postNotificationName:TestNotification object:self];
	fail_unless(noteCounter == 1,
		@"");
}

- (void) test_removeObserver_
{
	[noteCenter addObserver:self selector:@selector(handleNotification:) name:TestNotification object:nil];
	[noteCenter postNotificationName:TestNotification object:self];
	[noteCenter removeObserver:self];
	[noteCenter postNotificationName:TestNotification object:self];
	fail_unless(noteCounter == 1,
		@"");
}

- (void) test_removeObserver_name_object_
{
	[noteCenter addObserver:self selector:@selector(handleNotification:) name:TestNotification object:self];
	[noteCenter postNotificationName:TestNotification object:self];
	[noteCenter removeObserver:self name:TestNotification object:self];
	[noteCenter postNotificationName:TestNotification object:self];
	fail_unless(noteCounter == 1,
		@"");
}

- (void) test_postNotification_
{
	NSNotification *n = [NSNotification notificationWithName:TestNotification object:self];
	[noteCenter addObserver:self selector:@selector(handleNotification:) name:TestNotification object:nil];
	[noteCenter postNotification:n];
	fail_unless(noteCounter == 1,
		@"");
}

- (void) test_postNotificationName_object_
{
	NSNotification *n = [NSNotification notificationWithName:TestNotification object:self];
	[noteCenter addObserver:self selector:@selector(handleNotification:) name:TestNotification object:nil];
	[noteCenter postNotificationName:TestNotification object:self];
	fail_unless(noteCounter == 1,
		@"");
}

- (void) test_postNotificationName_object_userInfo_
{
	NSNotification *n = [NSNotification notificationWithName:TestNotification object:self];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"abcd",@"defg",@"hijk",@"foo",nil];
	[noteCenter addObserver:self selector:@selector(handleNotification:) name:TestNotification object:nil];
	[noteCenter postNotificationName:TestNotification object:self userInfo:nil];
	fail_unless(noteCounter == 1,
		@"");
}

- (void) handleNotification:(NSNotification *)n
{
	noteCounter++;
}

@end
