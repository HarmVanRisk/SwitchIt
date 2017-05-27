//
//  ViewController.m
//  SwitchIt
//
//  Created by Mark Sharvin on 27/05/2017.
//  Copyright © 2017 Mark Sharvin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTextFieldDelegate>
@property (weak) IBOutlet NSImageView *logoImageView;
@property (weak) IBOutlet NSTextView *thankYouLabel;
@property (weak) IBOutlet NSTextView *extenstionHelpView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupThankYouMessage];
    [self setupHelpView];
}

- (void)setupHelpView {
    NSMutableAttributedString *helpMessage = [[NSMutableAttributedString alloc] initWithString:@"Requirements:\n\tSwitchIt requires XCode 8 or later.\n\nHow to use SwitchIt?\n\t- Open a project in XCode\n\t- Open a file that contains a defined enum\n\t- Highlight the whole enum\n\t- In the XCode menu choose:\n\tEditor -> SwitchIt -> Create Switch\n\nTips:\n\t- Create a shortcut for the extension by going to\n\tXCode -> Preferences -> Key Bindings\n\tfilter the menu by switch. There you can set\n\tyour own shortcut."];
    [helpMessage addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial" size:15] range:NSMakeRange(0, helpMessage.length)];
    [helpMessage addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial Rounded MT Bold" size:17] range:[helpMessage.string rangeOfString:@"Requirements:"]];
    [helpMessage addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial Rounded MT Bold" size:17] range:[helpMessage.string rangeOfString:@"How to use SwitchIt?"]];
    [helpMessage addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial Rounded MT Bold" size:17] range:[helpMessage.string rangeOfString:@"Tips:"]];
    [[self.extenstionHelpView textStorage] appendAttributedString:helpMessage];
    self.extenstionHelpView.drawsBackground = YES;
    self.extenstionHelpView.editable = NO;
    self.extenstionHelpView.selectable = YES;
}

- (void)setupThankYouMessage {
    NSMutableAttributedString *thankYouMessage = [[NSMutableAttributedString alloc] initWithString:@"Thank you for using this extension.\n\nIf you like what you see let me know on twitter or Star my git repo here."];
    NSRange twitterRange = [thankYouMessage.string rangeOfString:@"twitter"];
    [thankYouMessage addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:@"https://twitter.com/ArcherSharvin"] absoluteString] range:twitterRange];
    NSRange gitRepoRange = [thankYouMessage.string rangeOfString:@"here"];
    [thankYouMessage addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:@"https://github.com/HarmVanRisk/SwitchIt"] absoluteString] range:gitRepoRange];
    [thankYouMessage addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial" size:16] range:NSMakeRange(0, thankYouMessage.length)];
    [[self.thankYouLabel textStorage] appendAttributedString:thankYouMessage];
    self.thankYouLabel.backgroundColor = [self colorWithHexColorString:@"ECECEC"];//[NSColor colorWithRed:236 green:236 blue:236 alpha:1];
    self.thankYouLabel.drawsBackground = YES;
    self.thankYouLabel.editable = NO;
    self.thankYouLabel.selectable = YES;
}

- (NSColor*)colorWithHexColorString:(NSString*)inColorString {
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString) {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [NSColor
              colorWithCalibratedRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte / 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:1.0];
    return result;
}

@end
