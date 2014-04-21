//
//  XYMessageEntity.h
//  DDMates
//
//  Created by Samuel Liu on 4/7/14.
//  Copyright (c) 2014 TelenavSoftware, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum
{
    XYMessageTypeText = 0,
    XYMessageTypePhoto = 1,
    XYMessageTypeAudio = 2,
    XYMessageTypeVideo = 3,
} XYMessageType;

@interface XYMessageEntity : NSManagedObject

@property (nonatomic, copy)     NSString *messageId;        // UUID
@property (nonatomic, retain)   NSNumber *userId;           // User ID
@property (nonatomic, copy)     NSString *text;             // text content
@property (nonatomic, copy)     NSString *contentUrl;       // remote url address
@property (nonatomic, copy)     NSString *contentFilename;  // local file path
@property (nonatomic, copy)     NSString *parameter;        // photo's w/h rate, audio's duration
@property (nonatomic, retain)   NSDate   *createDate;       // sent/received date
@property (nonatomic, retain)   NSNumber *outbound;         // flag of send/receive
@property (nonatomic, retain)   NSNumber *read;             // flag of read
@property (nonatomic, retain)   NSNumber *delivered;        // flag of delivered
@property (nonatomic, retain)   NSNumber *type;             // XYMessageType
@property (nonatomic, retain)   NSNumber *completed;        // upload/download complete?


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Public methods

@property (nonatomic, assign) Boolean isOutbound;
@property (nonatomic, assign) Boolean hasBeenRead;
@property (nonatomic, assign) Boolean hasBeenDelivered;
@property (nonatomic, assign) Boolean hasCompleted;

@property (nonatomic, readonly) NSString *photoFileName;  // return nil when the file not exist
@property (nonatomic, readonly) NSString *thumbnailFileName; // return nil when the file not exist
@property (nonatomic, readonly) NSString *photoUrl;
@property (nonatomic, readonly) float photoWidthHeightRate;

@property (nonatomic, readonly) NSString *audioFileName;  // return nil when the file not exist
@property (nonatomic, readonly) NSString *audioUrl;
@property (nonatomic, readonly) int audioDuration;

- (NSComparisonResult)compare:(id)object;

@end
