//
//	MusicPlaylistAction.m
//	ControlPlane
//
//	Created by David Jennes on 03/09/11.
//	Copyright 2011. All rights reserved.
//

#import "MusicPlaylistAction.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "Music.h"
#import "DSLogger.h"

@implementation MusicPlaylistAction

- (id) init {
	self = [super init];
	if (!self)
		return nil;
	
	playlist = [[NSString alloc] init];
	
	return self;
}

- (id) initWithDictionary: (NSDictionary *) dict {
	self = [super initWithDictionary: dict];
	if (!self)
		return nil;
	
	playlist = [[dict valueForKey: @"parameter"] copy];
	
	return self;
}

- (id) initWithOption: (NSString *) option {
	self = [super init];
	if (!self)
		return nil;
	
	playlist = [option copy];
	
	return self;
}

- (void) dealloc {
	[playlist release];
	[super dealloc];
}

- (NSMutableDictionary *) dictionary {
	NSMutableDictionary *dict = [super dictionary];
	
	[dict setObject: [[playlist copy] autorelease] forKey: @"parameter"];
	
	return dict;
}

- (NSString *) description {
	return [NSString stringWithFormat: NSLocalizedString(@"Playing '%@'", @""), playlist];
}

- (BOOL) execute: (NSString **) errorString {
	@try {
		MusicApplication *music = [SBApplication applicationWithBundleIdentifier: @"com.apple.Music"];
		
		// find library
		MusicSource *library = [music.sources objectWithName: @"Library"];
		
		// find playlist
		MusicPlaylist *p = [library.playlists objectWithName: playlist];
		
		// play random track
		[p playOnce: false];
	} @catch (NSException *e) {
		DSLog(@"Exception: %@", e);
		*errorString = NSLocalizedString(@"Couldn't play playlist!", @"In MusicPlaylistAction");
		return NO;
	}
	
	return YES;
}

+ (NSString *) helpText {
	return NSLocalizedString(@"The parameter for MusicPlaylist actions is the name of "
							 "the playlist to be played in Music.", @"");
}

+ (NSString *) creationHelpText {
	return NSLocalizedString(@"Play in Music (playlist):", @"");
}

+ (NSArray *) limitedOptions {
	NSMutableArray *options = nil;
	
	@try {
		MusicApplication *music = [SBApplication applicationWithBundleIdentifier: @"com.apple.Music"];
		
		// find library
		MusicSource *library = [music.sources objectWithName: @"Library"];
		SBElementArray *playlists = library.userPlaylists;
		options = [NSMutableArray arrayWithCapacity: playlists.count];
		
		// for each playlist
		for (MusicPlaylist *item in playlists)
			[options addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								item.name, @"option", item.name, @"description", nil]];
		
	} @catch (NSException *e) {
		DSLog(@"Exception: %@", e);
		options = [NSMutableArray array];
	}
	
	return options;
}

+ (NSString *) friendlyName {
    return NSLocalizedString(@"Play Music Playlist", @"");
}

+ (NSString *)menuCategory {
    return NSLocalizedString(@"Sound and Music", @"");
}

@end
