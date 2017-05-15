//
//  GlossaryItemView.m
//  Untitled
//
//  Created by Matthew Prockup on 2/8/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "GlossaryItemView.h"
#import <QuartzCore/CoreAnimation.h>


@implementation GlossaryItemView

@synthesize glossaryItem;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Juliesays : Tofix
        // Background of the glossary view is stretched vertically so it looks different from the other backgrounds
        
		backGroundImageView = [[UIImageView alloc] initWithImage:GLOSSARY_BACKGROUND];
		backGroundImageView.frame = frame;
		
		[self addSubview:backGroundImageView];
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight;

		title = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width, 44)];
		title.backgroundColor = [UIColor clearColor];
		title.font = GLOSSARY_TITLE_FONT;
		title.textColor = GLOSSARY_TITLE_TEXT_COLOR;

		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, title.frame.size.height, 200, 30)];
		[descriptionLabel setFont: GLOSSARY_DESCRIPTION_LABEL_FONT];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.text = @"Description";
		descriptionLabel.textColor = GLOSSARY_DESCRIPTION_LABEL_TEXT_COLOR;

		description = [[UITextView alloc] initWithFrame:CGRectMake(5,
																   descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height,
																   frame.size.width, 200)];
		description.backgroundColor = [UIColor clearColor];
		description.userInteractionEnabled = NO;
		description.autoresizesSubviews = YES;
		description.font = GLOSSARY_DESCRIPTION_FONT;
		description.textColor = GLOSSARY_DESCRIPTION_TEXT_COLOR;

		
		historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, description.frame.size.height + description.frame.origin.y, 100, 30)];
		[historyLabel setFont: GLOSSARY_HISTORY_LABEL_FONT];
		historyLabel.backgroundColor = [UIColor clearColor];
		historyLabel.text = @"History";
		historyLabel.textColor = GLOSSARY_HISTORY_LABEL_TEXT_COLOR;

		history = [[UITextView alloc] initWithFrame:CGRectMake(5,
																   historyLabel.frame.origin.y + historyLabel.frame.size.height,
																   frame.size.width, 200)];
		history.autoresizesSubviews = YES;
		history.userInteractionEnabled = NO;
		history.backgroundColor = [UIColor clearColor];
		[history setFont: GLOSSARY_HISTORY_FONT];
		history.textColor = GLOSSARY_HISTORY_TEXT_COLOR;

		[self addSubview:title];
		[self addSubview:descriptionLabel];
		[self addSubview:description];
		[self addSubview:historyLabel];
		[self addSubview:history];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width,history.frame.origin.y + history.frame.size.height+10);

    }
    return self;
}

- (void) setCustomFrame:(CGRect)frame {
    
    self.frame = frame;
    backGroundImageView.frame = frame;
    
    title.frame = CGRectMake(5, 0, frame.size.width, 44);
    
    descriptionLabel.frame = CGRectMake(5, title.frame.size.height, 200, 30);

    description.frame = CGRectMake(5,descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height,frame.size.width, 200);
    
    historyLabel.frame = CGRectMake(5, description.frame.size.height + description.frame.origin.y, 100, 30);
    
    history.frame = CGRectMake(5, historyLabel.frame.origin.y + historyLabel.frame.size.height,frame.size.width, 200);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width,history.frame.origin.y + history.frame.size.height +10);


}


- (void) setGlossaryItem:(GlossaryItem *) theItem {
		
	title.text = theItem.name;
    
	description.text = theItem.description;
	
	if(![theItem.history isEqualToString:@""]){
		historyLabel.text = @"History";
	}
	else{
		historyLabel.text = @"";
	}

	history.text = theItem.history;

	[self layoutSubviews];
    
	
}

-(void) layoutSubviews {
	[super layoutSubviews];
	
	// resize description text field
    
    CGRect frame = description.frame;
    NSLog(@"%@",description.text);
	frame.size = [description sizeThatFits:CGSizeMake(description.frame.size.width, FLT_MAX)];
	description.frame = frame;
	
	
    historyLabel.frame = CGRectMake(5, description.frame.size.height + description.frame.origin.y, 100, 30);
	history.frame = CGRectMake(5,
							   historyLabel.frame.origin.y + historyLabel.frame.size.height,
							   self.frame.size.width, 200);
	
	// resize history text field
	frame = history.frame;
    frame.size = [history sizeThatFits:CGSizeMake(history.frame.size.width, FLT_MAX)];
	history.frame = frame;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width,history.frame.origin.y + history.frame.size.height + 10);
}



- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
//    [super dealloc];
}


@end
