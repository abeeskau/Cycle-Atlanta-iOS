//
//  NoteViewController.m
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-3-1.
//
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "NoteViewController.h"
#import "LoadingView.h"
#import "Note.h"

#define kFudgeFactor	1.5
#define kInfoViewAlpha	0.8
#define kMinLatDelta	0.0039
#define kMinLonDelta	0.0034

@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize doneButton, flipButton, infoView, note;
@synthesize delegate;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithNote:(Note *)_note
{
	if (self = [super initWithNibName:@"NoteViewController" bundle:nil]) {
		NSLog(@"NoteViewController initWithNote");
		self.note = _note;
		noteView.delegate = self;
    }
    return self;
}

- (void)infoAction:(UIButton*)sender
{
	NSLog(@"infoAction");
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([infoView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([infoView superview])
		[infoView removeFromSuperview];
	else
		[self.view addSubview:infoView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([infoView superview] == self.view)
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)initInfoView
{
	infoView					= [[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)];
	infoView.alpha				= kInfoViewAlpha;
	infoView.backgroundColor	= [UIColor blackColor];
	
	UILabel *notesHeader		= [[UILabel alloc] initWithFrame:CGRectMake(9,85,160,25)];
	notesHeader.backgroundColor = [UIColor clearColor];
	notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
	notesHeader.opaque			= NO;
	notesHeader.text			= @"Details";
	notesHeader.textColor		= [UIColor whiteColor];
	[infoView addSubview:notesHeader];
	
	UITextView *notesText		= [[UITextView alloc] initWithFrame:CGRectMake(0,110,320,200)];
	notesText.backgroundColor	= [UIColor clearColor];
	notesText.editable			= NO;
	notesText.font				= [UIFont systemFontOfSize:16.0];
	notesText.text				= note.details;
	notesText.textColor			= [UIColor whiteColor];
	[infoView addSubview:notesText];
    
    UIImageView *noteImage      = [[UIImageView alloc] initWithFrame:CGRectMake(9, 160, 180, 240)];
    noteImage.backgroundColor   = [UIColor clearColor];
    noteImage.image= [UIImage imageWithData:note.image_data];
    [infoView addSubview:noteImage];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBarHidden = NO;
    
	if ( note )
	{
		// format date as a string
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *newDateString = [outputFormatter stringFromDate:note.recorded];
		
		self.navigationItem.prompt = [NSString stringWithFormat:@"Time: %@",newDateString];
        NSLog(@"NewDataString: %@", newDateString);
        
        NSString *title = [[NSString alloc] init];
        switch ([note.note_type intValue]) {
            case 0:
                title = @"Pavement issue";
                break;
            case 1:
                title = @"Traffic signal";
                break;
            case 2:
                title = @"Enforcement";
                break;
            case 3:
                title = @"Bike parking";
                break;
            case 4:
                title = @"Bike lane issue";
                break;
            case 5:
                title = @"Note this issue";
                break;
            case 6:
                title = @"Bike parking";
                break;
            case 7:
                title = @"Bike shops";
                break;
            case 8:
                title = @"Public restrooms";
                break;
            case 9:
                title = @"Secret passage";
                break;
            case 10:
                title = @"Water fountains";
                break;
            case 11:
                title = @"Note this asset";
                break;
            default:
                break;
        }

		self.title = title;
		
		if ( ![note.details isEqual: @""] || ([note.image_data length] != 0))
		{
			doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(infoAction:)];
			
			UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
			infoButton.showsTouchWhenHighlighted = YES;
			[infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
			flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
			self.navigationItem.rightBarButtonItem = flipButton;
			
			[self initInfoView];
		}
        
        CLLocationCoordinate2D noteCoordinate;
        noteCoordinate.latitude = [note.latitude doubleValue];
        noteCoordinate.longitude = [note.longitude doubleValue];
        NSLog(@"noteCoordinate is: %f, %f", noteCoordinate.latitude, noteCoordinate.longitude);
        
        MKPointAnnotation *notePoint = [[MKPointAnnotation alloc] init];
        notePoint.coordinate = noteCoordinate;
        notePoint.title = @"Note";
        [noteView addAnnotation:notePoint];
        
        
        MKCoordinateRegion region = { { noteCoordinate.latitude, noteCoordinate.longitude }, { 0.0078, 0.0068 }};
        [noteView setRegion:region animated:NO];
        
    }
    else{
        MKCoordinateRegion region = { { 33.749038, -84.388068 }, { 0.10825, 0.10825 } };
		[noteView setRegion:region animated:NO];
    }
    
    LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:999];
	//NSLog(@"loading: %@", loading);
	[loading performSelector:@selector(removeView) withObject:nil afterDelay:0.5];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    UIImage *thumbnailOriginal = [[UIImage alloc] init];
    thumbnailOriginal = [self screenshot];
    
    CGRect clippedRect  = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+160, self.view.frame.size.width, self.view.frame.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([thumbnailOriginal CGImage], clippedRect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGSize size;
    size.height = 72;
    size.width = 72;
    
    UIImage *thumbnail = [[UIImage alloc] init];
    thumbnail = shrinkImage1(newImage, size);
    
    NSData *thumbnailData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(thumbnail, 0)];
    NSLog(@"Size of Thumbnail Image(bytes):%d",[thumbnailData length]);
    NSLog(@"Size: %f, %f", thumbnail.size.height, thumbnail.size.width);
    
    [delegate getNoteThumbnail:thumbnailData];
}


UIImage *shrinkImage1(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return final;
}


- (UIImage*)screenshot
{
    NSLog(@"Screen Shoot");
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y+50);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *noteAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"notePin"];
    if ([note.note_type intValue]>=0 && [note.note_type intValue]<=5) {
        noteAnnotation.pinColor = MKPinAnnotationColorRed;
    }
    else if ([note.note_type intValue]>=6 && [note.note_type intValue]<=11) {
        noteAnnotation.pinColor = MKPinAnnotationColorGreen;
    }
    noteAnnotation.animatesDrop = YES;
    noteAnnotation.canShowCallout = YES;
    return noteAnnotation;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"NoteViewController");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MKMapViewDelegate methods


- (void)mapViewWillStartLoadingMap:(MKMapView *)noteView
{
	//NSLog(@"mapViewWillStartLoadingMap");
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)noteView withError:(NSError *)error
{
	NSLog(@"mapViewDidFailLoadingMap:withError: %@", [error localizedDescription]);
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)_noteView
{
	//NSLog(@"mapViewDidFinishLoadingMap");
	LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:999];
	//NSLog(@"loading: %@", loading);
	[loading removeView];
}

- (void)dealloc {
    self.note = nil;
    self.doneButton = nil;
    self.flipButton = nil;
    self.infoView = nil;
    
	[doneButton release];
	[flipButton release];
    [infoView release];
    [note release];
    
    [noteView release];
    
    [super dealloc];
}

@end