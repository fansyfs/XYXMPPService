//
//  XYXMPPService.h
//
//  Created by Samuel Liu on 4/17/14.
//  Copyright (c) 2014 TelenavSoftware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"

@interface XYXMPPService : NSObject
{
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
}

@property (nonatomic, copy) NSString *xmppHost;
@property (nonatomic, assign) int xmppPort;
@property (nonatomic, strong) XMPPJID *myJID;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
//@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
//@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
//@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
//@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
//@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
//@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

+ (XYXMPPService*)sharedXMPPService;
+ (void)cleanup;

- (void)setXMPPHost:(NSString*)host port:(int)port myJID:(XMPPJID*)jid;
- (BOOL)connect;
- (void)disconnect;

@end
