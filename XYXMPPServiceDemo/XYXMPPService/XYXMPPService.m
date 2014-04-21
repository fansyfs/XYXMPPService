//
//  XYXMPPService.m
//
//  Created by Samuel Liu on 4/17/14.
//  Copyright (c) 2014 TelenavSoftware Inc. All rights reserved.
//

#import "XYXMPPService.h"

@implementation XYXMPPService

static XYXMPPService *sharedXMPPService = nil;

+ (XYXMPPService*)sharedXMPPService
{
    @synchronized(self)
    {
        if(!sharedXMPPService)
            sharedXMPPService = [[XYXMPPService alloc] init];
    }

    return sharedXMPPService;
}

+ (void)cleanup
{
    sharedXMPPService = nil;
}

- (id)init
{
    self = [super init];
    if(self)
    {

    }
    return self;
}

- (void)dealloc
{
    [self teardownStream];
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
///////////////////////////////////////////////////////////////////////////////////////////////

- (void)initCoreData
{
    [self managedObjectContext];
}

- (NSString*)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (managedObjectModel)
        return managedObjectModel;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"XYMessageModel" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator)
        return persistentStoreCoordinator;
    
	NSString *storePath = [[self documentPath] stringByAppendingString:@"/xymessage/db/"];
    NSString *imgPath = [[self documentPath] stringByAppendingString:@"/xymessage/image/"];
    NSString *audioPath = [[self documentPath] stringByAppendingString:@"/xymessage/audio/"];
    NSString *groupAudioPath = [[self documentPath] stringByAppendingString:@"/xymessage/groupaudio/"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:storePath])
	{
		[fileManager createDirectoryAtPath:storePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    if(![fileManager fileExistsAtPath:imgPath])
	{
		[fileManager createDirectoryAtPath:imgPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    if(![fileManager fileExistsAtPath:audioPath])
	{
		[fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    if(![fileManager fileExistsAtPath:groupAudioPath])
	{
		[fileManager createDirectoryAtPath:groupAudioPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    
	NSURL *storeUrl = [NSURL fileURLWithPath:[storePath stringByAppendingFormat:@"%@.sqlite", _myJID.user]];

	NSError *error;
    
    //	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    //							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    //							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
    //                             nil];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
    if (!store)
    {
		NSLog(@"NSPersistentStore error: %@", error.debugDescription);
    }
	else
    {
        NSLog(@"NSPersistentStore successful:%@", storeUrl);
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext)
        return managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	_xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		_xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	_xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
//	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
//    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
//	
//	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
//	
//	xmppRoster.autoFetchRoster = YES;
//	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
//	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
//	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
//	
//	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
//	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
//    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
//    
//    xmppCapabilities.autoFetchHashedCapabilities = YES;
//    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[_xmppReconnect         activate:_xmppStream];
//	[xmppRoster            activate:xmppStream];
//	[xmppvCardTempModule   activate:xmppStream];
//	[xmppvCardAvatarModule activate:xmppStream];
//	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    [_xmppStream setHostName:_xmppHost];//@"talk.google.com"];
	[_xmppStream setHostPort:_xmppPort];//5222];

	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
	[_xmppStream removeDelegate:self];
//	[xmppRoster removeDelegate:self];
	
	[_xmppReconnect         deactivate];
//	[xmppRoster            deactivate];
//	[xmppvCardTempModule   deactivate];
//	[xmppvCardAvatarModule deactivate];
//	[xmppCapabilities      deactivate];
	
	[_xmppStream disconnect];
	
	_xmppStream = nil;
	_xmppReconnect = nil;
//    xmppRoster = nil;
//	xmppRosterStorage = nil;
//	xmppvCardStorage = nil;
//    xmppvCardTempModule = nil;
//	xmppvCardAvatarModule = nil;
//	xmppCapabilities = nil;
//	xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [_xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setXMPPHost:(NSString*)host port:(int)port myJID:(XMPPJID*)jid
{
    self.xmppHost = host;
    self.xmppPort = port;
    self.myJID = jid;
    
    [self setupStream];
    [self initCoreData];
}

- (BOOL)connect
{
	if (![_xmppStream isDisconnected]) {
		return YES;
	}
    
//	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
//	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
//    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
//	if (myJID == nil || myPassword == nil) {
//		return NO;
//	}

	[_xmppStream setMyJID:_myJID];

	NSError *error = nil;
	if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		NSLog(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[_xmppStream disconnect];
}

@end
