//
//  constants.h
//  Test1
//
//  Created by Matthew Prockup on 11/7/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//
//  This header defines the server addresses through which the app looks for content

//////////////////////////////////
// CURRENT RELEASE DEFINITION
//////////////////////////////////
#define IS_YOUR_NEW_RELEASE

//////////////////////////////////
// POSSIBLE RELEASE DEFINITIONS
//////////////////////////////////
//  #define IS_LIVE_RELEASE
//  #define IS_EXCITE_DEV
//  #define IS_METLAB_DEV
//  #define IS_METLAB_MUSIC_DEV
//  #define IS_EXCITE_MUSIC_DEV
//  #define IS_YOUR_NEW_RELEASE
//////////////////////////////////

//This is an example of a build type
#ifdef IS_YOUR_NEW_RELEASE
    #define ADDRESS_OF_SERVER @"serverName.yourDomain.org";
    #define IMAGE_SERVER @"http://serverName.yourDomain.org/images/";   // folder that contains images on the server
    #define SSID @"your_ssid" //will check if its in your network (needed for multicast) for 'live' performance
    #define INFO_LINK @"http://serverName.yourDomain.org"
#endif


/////////////////////////////////////////
//  BRANDING IMAGES                    //
//  Dynamically Loaded from webserver  //
//  var/www/images/AppAssets           //
/////////////////////////////////////////
//SPLASH SCREEN
#define SPLASH_IMAGE_32 @"splashPlaceHolder32.png"
#define SPLASH_IMAGE_169 @"splashPlaceHolder169.png"

//ALBUM VIEW BG
#define SELECT_PIECES_BG_32 @"defaultBackground32.png"
#define SELECT_PIECES_BG_169 @"defaultBackground169.png"

//FRONT PAGE HELP OVERLAY
#define MAIN_WINDOW_HELP_32 @"AlbumHelp32.png"
#define MAIN_WINDOW_HELP_169 @"AlbumHelp169.png"

//INFO SCREEN
#define INFO_SCREEN_32 @"InfoScreen32.png"
#define INFO_SCREEN_169 @"InfoScreen169.png"

//SLIDE VIEW HELP OVERLAY WITH TRACKS
#define SLIDE_VIEW_HELP_TRACKS_32 @"SlideViewHelp32.png"
#define SLIDE_VIEW_HELP_TRACKS_169 @"SlideViewHelp169.png"

//SLIDE VIEW HELP OVERLAY WITH NO TRACKS
#define SLIDE_VIEW_HELP_NO_TRACKS_32 @"SlideViewHelp32.png"
#define SLIDE_VIEW_HELP_NO_TRACKS_169 @"SlideViewHelp169.png"

//SLIDE VIEW BG IMAGE
#define SLIDE_BACKGROUND_IMAGE



/////////////////
//  UI IMAGES  //
/////////////////

//ICON IMAGES all 1x1 aspect ratio
#define TRASH_ICON_IMAGE            [UIImage imageNamed:@"deletePieceIcon.png"]
#define GLOSSARY_ICON_FRONT_IMAGE   [UIImage imageNamed:@"glossaryIconFront.png"]
#define BRIGHTNESS_ICON_FRONT_IMAGE [UIImage imageNamed:@"brightnessIconFront.png"]
#define HELP_ICON_FRONT_IMAGE       [UIImage imageNamed:@"helpIconFront.png"]
#define INFO_ICON_FRONT_IMAGE       [UIImage imageNamed:@"infoIconFront.png"]

#define BRIGHTNESS_ICON_SLIDE_IMAGE [UIImage imageNamed:@"brightness.png"]
#define FAVORITES_ICON_SLIDE_IMAGE  [UIImage imageNamed:@"star.png"] //not fully implemented yet
#define HELP_ICON_SLIDE_IMAGE       [UIImage imageNamed:@"helpIcon.png"]
#define TEXT_SIZE_ICON_SLIDE_IMAGE  [UIImage imageNamed:@"textSizeIcon.png"]
#define TRACK_TIP_ICON_IMAGE        [UIImage imageNamed:@"tip.png"]

#define MAIN_BACKGROUND [UIImage imageNamed:@"blackBackground.png"]
#define GLOSSARY_BACKGROUND [UIImage imageNamed:@"blackBackground.png"]
#define MARKER_BAR_BACKGROUND [UIImage imageNamed:@"blackBackground.png"]

////////////////////////////
//  SLIDE CONTENT FONTS   //
////////////////////////////
// These must be text strings and not objects
// They are inserted into the HTML templates
#define SLIDE_FONT_FAMILY_A     @"Helvetica"
#define SLIDE_FONT_FAMILY_B     @"Helvetica"
#define SLIDE_TEXT_COLOR        @"#FFFFFF"
#define SLIDE_LINK_TEXT_COLOR   @"#FFFF0B"


//////////////////////
//  UI FONTS        //
//////////////////////

//FRONT PAGE
#define ALBUM_COMPOSER_FONT             [UIFont fontWithName:@"Helvetica" size:20]
#define ALBUM_COMPOSER_TEXT_COLOR       [UIColor whiteColor]

#define ALBUM_NAME_FONT                 [UIFont fontWithName:@"Helvetica" size:20]
#define ALBUM_NAME_TEXT_COLOR           [UIColor whiteColor]

#define ALBUM_MVT_FONT                  [UIFont fontWithName:@"Helvetica" size:20]
#define ALBUM_MVT_TEXT_COLOR            [UIColor whiteColor]

#define ALBUM_LIVE_BUTTON_TEXT_COLOR    [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]
#define ALBUM_LIVE_BUTTON_FONT          [UIFont fontWithName:@"Helvetica" size:16]

//SLIDES
#define PROGRAM_NOTES_BUTTON_FONT       [UIFont fontWithName:@"Helvetica" size:16]
#define PROGRAM_NOTES_BUTTON_TEXT_COLOR [UIColor whiteColor]

#define MAP_FONT                        [UIFont fontWithName:@"Helvetica" size:14]
#define MAP_TEXT_COLOR                  [UIColor whiteColor]

#define TAB_FONT                        [UIFont fontWithName:@"Helvetica" size:15]
#define TAB_TEXT_COLOR                  [UIColor colorWithRed:185.0/255.0 green:175/255.0 blue:150.0/255.0 alpha:1.0]
#define TAB_BG_COLOR                    [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]

#define SELECTED_TAB_FONT               [UIFont fontWithName:@"Helvetica" size:17]
#define SELECTED_TAB_TEXT_COLOR         [UIColor colorWithRed:185.0/255.0 green:175/255.0 blue:150.0/255.0 alpha:1.0]
#define SELECTED_TAB_BG_COLOR           [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.7]

#define SLIDE_POSITION_FONT             [UIFont fontWithName:@"Helvetica" size:14]
#define SLIDE_POSITION_TEXT_COLOR       [UIColor whiteColor]

//GLOSSARY
#define GLOSSARY_TITLE_FONT                     [UIFont fontWithName:@"Helvetica" size:28]
#define GLOSSARY_TITLE_TEXT_COLOR               [UIColor whiteColor]
#define GLOSSARY_DESCRIPTION_LABEL_FONT         [UIFont fontWithName:@"Helvetica" size:20]
#define GLOSSARY_DESCRIPTION_LABEL_TEXT_COLOR   [UIColor whiteColor]
#define GLOSSARY_HISTORY_LABEL_FONT             [UIFont fontWithName:@"Helvetica" size:20]
#define GLOSSARY_HISTORY_LABEL_TEXT_COLOR       [UIColor whiteColor]
#define GLOSSARY_DESCRIPTION_FONT               [UIFont fontWithName:@"Helvetica" size:16]
#define GLOSSARY_DESCRIPTION_TEXT_COLOR         [UIColor whiteColor]
#define GLOSSARY_HISTORY_FONT                   [UIFont fontWithName:@"Helvetica" size:16]
#define GLOSSARY_HISTORY_TEXT_COLOR             [UIColor whiteColor]
#define GLOSSARY_TABLE_FONT                     [UIFont fontWithName:@"Helvetica" size:16]
#define GLOSSARY_TABLE_FONT_COLOR               [UIColor whiteColor]
#define GLOSSARY_TABLE_SELECTED_FONT            [UIFont fontWithName:@"Helvetica" size:16]
#define GLOSSARY_TABLE_SELECTED_FONT_COLOR      [UIColor whiteColor]


/////////////////
//  UI COLORS  //
/////////////////
#define ALBUM_COMPOSER_BG_COLOR [UIColor blackColor]
#define ALBUM_BG_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]
#define ALBUM_MVT_BG_COLOR [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]
#define PROGRAM_NOTES_BUTTON_BG_COLOR [UIColor grayColor]
#define TOOLBAR_BG_COLOR [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]


///////////////////////////
//  SYSTEM DEFININTIONS  //
///////////////////////////
#define IPAD_EQUALS_IPHONE //THIS MAKES RESOLUTIONS SCALE ON IPAD
//  #define TEXT_REPLACE //Replace weird characters manually, not need is using UDF-8 everywhere
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


