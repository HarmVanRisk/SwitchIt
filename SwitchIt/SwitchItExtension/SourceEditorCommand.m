//
//  SourceEditorCommand.m
//  SwitchItExtension
//
//  Created by Mark Sharvin on 27/05/2017.
//  Copyright © 2017 Mark Sharvin. All rights reserved.
//

#import "SourceEditorCommand.h"

/*
 TODO: Clean code and make it more readable
 */

static NSString *const kEmptyString = @"";
static NSString *const kEmptySpace = @" ";
static NSString *const kCommaString = @",";
static NSString *const kCommaSeparatorString = @",";
static NSString *const kOpenCurlyBracket = @"{";
static NSString *const kCloseCurlyBracket = @"}";
static NSString *const kEqualsKey = @"=";
static NSString *const kCaseKey = @"case ";
static NSString *const kObjcStartOfSwitch = @"switch(<#Value#>) {\n";
static NSString *const kObjcCaseFormat = @"%@case %@: {\n%@%@break;\n%@}\n";
static NSString *const kSwiftStartOfSwitch = @"switch <#Value#> {\n";
static NSString *const kSwiftCaseFormat = @"%@case .%@: \n%@%@break\n";

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    //+1 to make it inclusive of the last selected line
    NSUInteger length = range.end.line - range.start.line + 1;
    NSArray *selectedLines = [invocation.buffer.lines subarrayWithRange:NSMakeRange(range.start.line, length)];
    BOOL isSwiftEnum = NO;
    for (NSString *enumLine in selectedLines) {
        if ([enumLine containsString:kCaseKey]) {
            isSwiftEnum = YES;
            break;
        }
    }
    NSString *fullSwitch = isSwiftEnum ? [self expandedSwitchInSwift:invocation withSelectedLines:selectedLines] : [self expandedSwitchInObjectiveC:invocation withSelectedLines:selectedLines];
    if (fullSwitch.length > 0) {
        [invocation.buffer.lines insertObject:fullSwitch atIndex:range.end.line+2];
    }
    completionHandler(nil);
}

- (NSString *)expandedSwitchInObjectiveC:(XCSourceEditorCommandInvocation *)invocation withSelectedLines:(NSArray *)selectedLines {
    NSMutableCharacterSet *setToBeTrimmed = [NSMutableCharacterSet characterSetWithCharactersInString:kCommaString];
    [setToBeTrimmed formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tabIndent = [kEmptyString stringByPaddingToLength:invocation.buffer.tabWidth withString:kEmptySpace startingAtIndex:0];
    NSString *switchContents = kEmptyString;
    for (NSString *line in selectedLines) {
        BOOL isBeginningOrEnding = [line containsString:kOpenCurlyBracket] || [line containsString:kCloseCurlyBracket];
        if (!isBeginningOrEnding) {
            NSString *foundCase = line;
            foundCase = [foundCase stringByTrimmingCharactersInSet:setToBeTrimmed];
            if (foundCase.length > 0) {
                switchContents = [self switchContentsForGivenLine:foundCase withTabIndent:tabIndent totalContents:switchContents andIsSwift:NO];
            }
        }
    }
    NSString *fullSwitch = kEmptyString;
    if (switchContents.length > 0) {
        fullSwitch = kObjcStartOfSwitch;
        fullSwitch = [fullSwitch stringByAppendingString:switchContents];
        fullSwitch = [fullSwitch stringByAppendingString:kCloseCurlyBracket];
    }
    
    return fullSwitch;
}

- (NSString *)expandedSwitchInSwift:(XCSourceEditorCommandInvocation *)invocation withSelectedLines:(NSArray *)selectedLines {
    NSCharacterSet *setToBeTrimed = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *tabIndent = [kEmptyString stringByPaddingToLength:invocation.buffer.tabWidth withString:kEmptySpace startingAtIndex:0];
    NSString *switchContents = kEmptyString;
    for (NSString *line in selectedLines) {
        BOOL isBeginningOrEnding = [line containsString:kOpenCurlyBracket] || [line containsString:kCloseCurlyBracket];
        if (!isBeginningOrEnding) {
            NSString *foundCase = line;
            foundCase = [foundCase stringByReplacingOccurrencesOfString:kCaseKey withString:kEmptyString];
            foundCase = [foundCase stringByTrimmingCharactersInSet:setToBeTrimed];
            if (foundCase.length > 0) {
                switchContents = [self switchContentsForGivenLine:foundCase withTabIndent:tabIndent totalContents:switchContents andIsSwift:YES];
            }
        }
    }
    NSString *fullSwitch = kEmptyString;
    if (switchContents.length > 0) {
        fullSwitch = kSwiftStartOfSwitch;
        fullSwitch = [fullSwitch stringByAppendingString:switchContents];
        fullSwitch = [fullSwitch stringByAppendingString:kCloseCurlyBracket];
    }
    return fullSwitch;
}

- (NSString *)switchContentsForGivenLine:(NSString *)foundCase withTabIndent:(NSString *)tabIndent totalContents:(NSString *)switchContents andIsSwift:(BOOL)isSwift {
    if ([foundCase containsString:kEqualsKey] && ![foundCase containsString:kCommaString]) {
        //If the enum has been assigned a value we need to ignore it
        NSRange rangeOfFoundEquals = [foundCase rangeOfString:kEqualsKey];
        foundCase = [foundCase stringByReplacingCharactersInRange:NSMakeRange(rangeOfFoundEquals.location, foundCase.length - rangeOfFoundEquals.location) withString:kEmptyString];
    }
    if ([foundCase containsString:kCommaString]) {
        //If someone by chance has put it all on one line we can still cater for it
        switchContents = [self processMultipleCasesOnFoundLine:foundCase tabIndent:tabIndent switchContents:switchContents isSwift:isSwift];
    } else {
        if (isSwift) {
            switchContents = [switchContents stringByAppendingString:[NSString stringWithFormat:kSwiftCaseFormat,tabIndent,foundCase,tabIndent,tabIndent]];
        } else {
            switchContents = [switchContents stringByAppendingString:[NSString stringWithFormat:kObjcCaseFormat,tabIndent,foundCase,tabIndent,tabIndent,tabIndent]];
        }
    }
    return switchContents;
}

- (NSString *)processMultipleCasesOnFoundLine:(NSString *)foundCase tabIndent:(NSString *)tabIndent switchContents:(NSString *)switchContents isSwift:(BOOL)isSwift {
    for (NSString *foundSwitchOnOneLine in [foundCase componentsSeparatedByString:kCommaSeparatorString]) {
        NSString *otherFoundCase = foundSwitchOnOneLine;
        otherFoundCase = [otherFoundCase stringByReplacingOccurrencesOfString:kEmptySpace withString:kEmptyString];
        if ([otherFoundCase containsString:kEqualsKey]) {
            //If the enum has been assigned a value we need to ignore it even when we are looping through
            NSRange rangeOfFoundEquals = [otherFoundCase rangeOfString:kEqualsKey];
            otherFoundCase = [otherFoundCase stringByReplacingCharactersInRange:NSMakeRange(rangeOfFoundEquals.location, otherFoundCase.length - rangeOfFoundEquals.location) withString:kEmptyString];
        }
        if (isSwift) {
            switchContents = [switchContents stringByAppendingString:[NSString stringWithFormat:kSwiftCaseFormat,tabIndent,otherFoundCase,tabIndent,tabIndent]];
        } else {
            switchContents = [switchContents stringByAppendingString:[NSString stringWithFormat:kObjcCaseFormat,tabIndent,otherFoundCase,tabIndent,tabIndent,tabIndent]];
        }
    }
    return switchContents;
}


@end
