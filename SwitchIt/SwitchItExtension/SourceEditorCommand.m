//
//  SourceEditorCommand.m
//  SwitchItExtension
//
//  Created by Mark Sharvin on 27/05/2017.
//  Copyright © 2017 Mark Sharvin. All rights reserved.
//

#import "SourceEditorCommand.h"

/*
 TODO: Handle objc enums that are all on one line
 TODO: Clean code and make it more readable
 */

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    //+1 to make it inclusive of the last selected line
    NSUInteger length = range.end.line - range.start.line + 1;
    NSArray *selectedLines = [invocation.buffer.lines subarrayWithRange:NSMakeRange(range.start.line, length)];
    BOOL isSwiftEnum = NO;
    for (NSString *enumLine in selectedLines) {
        if ([enumLine containsString:@"case "]) {
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
    NSMutableCharacterSet *setToBeTrimed = [NSMutableCharacterSet characterSetWithCharactersInString:@","];
    [setToBeTrimed formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tabIndent = [@"" stringByPaddingToLength:invocation.buffer.tabWidth withString:@" " startingAtIndex:0];
    NSString *switchContents = @"";
    for (NSString *line in selectedLines) {
        BOOL isBeginningOrEnding = [line containsString:@"{"] || [line containsString:@"}"];
        if (!isBeginningOrEnding) {
            NSString *foundCase = line;
            foundCase = [foundCase stringByTrimmingCharactersInSet:setToBeTrimed];
            if ([foundCase containsString:@"="]) {
                NSRange rangeOfFoundEquals = [foundCase rangeOfString:@"="];
                foundCase = [foundCase stringByReplacingCharactersInRange:NSMakeRange(rangeOfFoundEquals.location, foundCase.length - rangeOfFoundEquals.location) withString:@""];
            }
            if (foundCase.length > 0) {
                switchContents = [switchContents stringByAppendingString:[NSString stringWithFormat:@"%@case %@: {\n%@%@break;\n%@}\n",tabIndent,foundCase,tabIndent,tabIndent,tabIndent]];
            }
        }
    }
    NSString *fullSwitch = @"";
    if (switchContents.length > 0) {
        fullSwitch = @"switch(<#Value#>) {\n";
        fullSwitch = [fullSwitch stringByAppendingString:switchContents];
        fullSwitch = [fullSwitch stringByAppendingString:@"}"];
    }
    
    return fullSwitch;
}

- (NSString *)expandedSwitchInSwift:(XCSourceEditorCommandInvocation *)invocation withSelectedLines:(NSArray *)selectedLines {
    NSCharacterSet *setToBeTrimed = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *fullSwitch = @"switch <#Value#> {\n";
    NSString *tabIndent = [@"" stringByPaddingToLength:invocation.buffer.tabWidth withString:@" " startingAtIndex:0];
    for (NSString *line in selectedLines) {
        BOOL isBeginningOrEnding = [line containsString:@"{"] || [line containsString:@"}"];
        if (!isBeginningOrEnding) {
            NSString *foundCase = line;
            foundCase = [foundCase stringByReplacingOccurrencesOfString:@"case " withString:@""];
            foundCase = [foundCase stringByTrimmingCharactersInSet:setToBeTrimed];
            if ([foundCase containsString:@"="]) {
                NSRange rangeOfFoundEquals = [foundCase rangeOfString:@"="];
                foundCase = [foundCase stringByReplacingCharactersInRange:NSMakeRange(rangeOfFoundEquals.location, foundCase.length - rangeOfFoundEquals.location) withString:@""];
            }
            if (foundCase.length > 0) {
                if ([foundCase containsString:@","]) {
                    for (NSString *foundSwitchOnOneLine in [foundCase componentsSeparatedByString:@", "]) {
                        fullSwitch = [fullSwitch stringByAppendingString:[NSString stringWithFormat:@"%@case .%@: \n%@%@break\n",tabIndent,foundSwitchOnOneLine,tabIndent,tabIndent]];
                    }
                } else {
                    fullSwitch = [fullSwitch stringByAppendingString:[NSString stringWithFormat:@"%@case .%@: \n%@%@break\n",tabIndent,foundCase,tabIndent,tabIndent]];
                }
            }
        }
    }
    fullSwitch = [fullSwitch stringByAppendingString:@"}"];
    return fullSwitch;
}


@end
