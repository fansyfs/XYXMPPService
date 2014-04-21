//
//  XYMessageEntity.m
//  DDMates
//
//  Created by Samuel Liu on 4/7/14.
//  Copyright (c) 2014 TelenavSoftware, Inc. All rights reserved.
//

#import "XYMessageEntity.h"


@implementation XYMessageEntity

@dynamic messageId;
@dynamic userId;
@dynamic text;
@dynamic contentUrl;
@dynamic contentFilename;
@dynamic parameter;
@dynamic createDate;
@dynamic outbound;
@dynamic read;
@dynamic delivered;
@dynamic type;
@dynamic completed;

- (Boolean)isOutbound
{
    return [[self outbound] boolValue];
}

- (void)setIsOutbound:(Boolean)flag
{
    [self setOutbound:[NSNumber numberWithBool:flag]];
}

- (Boolean)hasBeenRead
{
    return [[self read] boolValue];
}

- (void)setHasBeenRead:(Boolean)flag
{
    [self setRead:[NSNumber numberWithBool:flag]];
}

- (Boolean)hasBeenDelivered
{
    return [[self delivered] boolValue];
}

- (void)setHasBeenDelivered:(Boolean)flag
{
    [self setDelivered:[NSNumber numberWithBool:flag]];
}

- (Boolean)hasCompleted
{
    return [[self completed] boolValue];
}

- (void)setHasCompleted:(Boolean)flag
{
    [self setCompleted:[NSNumber numberWithBool:flag]];
}

- (NSComparisonResult)compare:(id)object
{
    XYMessageEntity *msg = (XYMessageEntity*)object;
    if(self.hasBeenRead == NO && msg.hasBeenRead == YES)
    {
        return NSOrderedAscending;
    }
    else if(self.hasBeenRead == YES && msg.hasBeenRead == NO)
    {
        return NSOrderedDescending;
    }
    else
    {
        // turnover
        NSComparisonResult result = [self.createDate compare:msg.createDate];

        if(result == NSOrderedAscending)
            return NSOrderedDescending;
        else if(result == NSOrderedDescending)
            return NSOrderedAscending;
        else
            return result;
    }
}

#pragma mark photo
-(NSString*)photoFileName
{
    if(self.contentFilename && [[NSFileManager defaultManager] fileExistsAtPath:self.contentFilename])
        return self.contentFilename;
    else
        return nil;
}

-(NSString*)thumbnailFileName
{
    if(self.contentFilename)
    {
        NSString *pathname = [self.contentFilename substringToIndex:self.contentFilename.length - 4];
        NSString *suffix = [self.contentFilename substringFromIndex:self.contentFilename.length - 4];
        NSString *thumbnail = [NSString stringWithFormat:@"%@-thumb%@", pathname, suffix];
        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnail])
            return thumbnail;
        else
            return nil;
    }
    else
    {
        return nil;
    }
}

-(NSString*)photoUrl
{
    if(self.contentUrl)
        return self.contentUrl;
    else
        return nil;
}

-(float)photoWidthHeightRate
{
    if(!self.parameter)
        return 0.0f;
    else
        return [self.parameter floatValue];
}

#pragma mark voice
-(NSString*)audioFileName
{
    if(self.contentFilename && [[NSFileManager defaultManager] fileExistsAtPath:self.contentFilename])
        return self.contentFilename;
    else
        return nil;
}

-(NSString*)audioUrl
{
    if(self.contentUrl)
        return self.contentUrl;
    else
        return nil;
}

-(int)audioDuration
{
    if(!self.parameter)
        return 0;
    else
        return [self.parameter intValue];
}

@end
