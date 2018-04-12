//
//  NBCodeProducer.m
//  CodeProducer
//
//  Created by Nikos Bitoulas on 8/7/17.
//  Copyright © 2017 Nikos Bitoulas. All rights reserved.
//

#import "NBCodeProducer.h"
#import "ObjectiveSugar.h"
#import "NBOutletData.h"

@interface NBCodeProducer()

@property(nonatomic, strong) NSArray<NBOutletData *> *outlets;
@property(nonatomic, copy) NSString *className;
@property(nonatomic, copy) NSString *categoryName;

@end

@implementation NBCodeProducer

-(void)produceCodeWithOutlets:(NSArray<NBOutletData *> *)outlets
                    className:(NSString *)className
                 categoryName:(NSString *)categoryName {
    _outlets = outlets;
    _className = className;
    _categoryName = categoryName;
    
    NSMutableString *mutString = [NSMutableString new];
    
    [mutString appendString:[self produceImports]];
    [mutString appendString:@"\n"];
    [mutString appendString:[self producePrivateInterface]];
    [mutString appendString:@"\n"];
    [mutString appendFormat:@"@implementation %@\n\n", _className];
    
    if ([self isView]) {
        [mutString appendString:[self produceInitWithFrameMethod]];
        [mutString appendString:@"\n"];
    }
    if ([self isViewController]) {
        [mutString appendString:[self produceLoadViewMethod]];
        [mutString appendString:@"\n"];
    }
    [mutString appendString:[self produceConstructUIMethod]];
    [mutString appendString:@"\n"];
    [mutString appendString:[self produceLayoutUIMethod]];
    [mutString appendString:@"\n"];
    [mutString appendString:[self produceConstructorMacros]];
    [mutString appendString:@"\n"];
    [mutString appendString:[self produceConstructorMethods]];
    [mutString appendString:@"\n"];
    [mutString appendString:[self produceConstructorHelperMethods]];
    [mutString appendString:@"\n"];
    
    if ([self isViewController]) {
        [mutString appendString:[self produceActionMethods]];
        [mutString appendString:@"\n"];
        [mutString appendString:[self produceDelegateNotificationMethods]];
        [mutString appendString:@"\n"];
    }
    
    [mutString appendString:@"@end\n"];

    if ([self isViewController]) {
        [mutString appendString:@"\n\n\n"];
        // produce header file
        [mutString appendString:[self produceHeaderFile]];
    }

    NSLog(@"Code:\n\n%@", mutString);
}

-(NSString *)produceImports {
    NSString *classHeader = [NSString stringWithFormat:@"#import \"%@.h\"\n", self.className];

    return
    [classHeader stringByAppendingString:
    @"#import \"COUIHelper.h\"\n"
    @"#import \"COMacros.h\"\n"
    @"#import \"KeepLayout.h\"\n"
    @"#import \"ObjectiveSugar.h\"\n"
    @"#import \"UIView+AddSubviews.h\"\n"
    @"#import \"UIImageView+ImageNamed.h\"\n"
    @"#import \"UILabel+Modifiers.h\"\n"
    @""];
}

-(NSString *)producePrivateInterface {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendFormat:@"@interface %@()\n\n", _className];
    [_outlets each:^(NBOutletData *outlet) {
        NSString *line = [NSString stringWithFormat:@"@property(nonatomic, strong) IBOutlet %@ *%@;\n", outlet.className, outlet.name];
        [mutString appendString:line];
    }];
    
    [mutString appendString:@"\n"];
    
    [mutString appendString:@"@end\n"];
    return [mutString copy];
}


-(NSString *)produceInitWithFrameMethod {
    return
    @"-(instancetype)initWithFrame:(CGRect)frame {\n"
    @"self = [super initWithFrame:frame];\n"
    @"if (self) {\n"
    @"[self constructUI];\n"
    @"[self layoutUI];\n"
    @"}\n"
    @"return self;\n"
    @"}\n"
    @"";
    
}

-(NSString *)produceLoadViewMethod {
    return
    @"-(void)loadView {\n"
    @"self.view = [UIView new];\n"
    @"self.view.backgroundColor = [UIColor whiteColor];\n"
    @"\n"
    @"[self constructUI];\n"
    @"[self layoutUI];\n"
    @"}\n"
    @"";
    
}

-(NSString *)produceConstructUIMethod {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"-(void)constructUI {\n"];

    NSString *superviewToAdd = ([self isView] ? @"self" : @"self.view");
    [mutString appendFormat:@"[%@ addSubviews:@[", superviewToAdd];
    [_outlets eachWithIndex:^(NBOutletData *outlet, NSUInteger index) {
        [mutString appendString:@"self."];
        [mutString appendString:outlet.name];
        [mutString appendString:@", "];
        if ((index+1)%3 == 0) {
            [mutString appendString:@"\n"];
        }
    }];
    [mutString appendString:@"\n]];\n"];
    [mutString appendString:@"}\n"];
    return [mutString copy];
}

-(NSString *)produceLayoutUIMethod {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"-(void)layoutUI {\n"];
    [_outlets eachWithIndex:^(NBOutletData *outlet, NSUInteger index) {
        NSString *verticalConstraint = [self verticalConstraintWithOutlet:outlet index:index];
        NSString *horizontalConstraint = [self horizontalConstraintWithOutlet:outlet];
        
        [mutString appendString:verticalConstraint];
        [mutString appendString:horizontalConstraint];
        [mutString appendString:@"\n"];
    }];
    
    [mutString appendString:@"}\n"];
    return [mutString copy];
}

-(NSString *)verticalConstraintWithOutlet:(NBOutletData *)outlet index:(NSUInteger)index {
    NSMutableString *mutString = [NSMutableString new];

    if (index == 0) {
        [mutString appendFormat:@"self.%@.keepTopInset.equal = 16;\n", outlet.name];
    } else {
        NSString *previousPropertyName = [self.outlets[index-1] name];
        [mutString appendFormat:@"self.%@.keepTopOffsetTo(self.%@).equal = 16;\n", outlet.name, previousPropertyName];
    }
    if ([self isHorizontalLineOutlet:outlet]) {
        [mutString appendFormat:@"self.%@.keepHeight.equal = 0.5;\n", outlet.name];
    } else if ([self isButtonOutlet:outlet]) {
        [mutString appendFormat:@"self.%@.keepHeight.equal = 44;\n", outlet.name];
    }
    
    if (index == _outlets.count - 1) {
        [mutString appendFormat:@"self.%@.keepBottomInset.equal = 16;\n", outlet.name];
    }
    
    return [mutString copy];
}

-(NSString *)horizontalConstraintWithOutlet:(NBOutletData *)outlet {
    NSMutableString *mutString = [NSMutableString new];

    if ([self isLabelOutlet:outlet] || [self isButtonOutlet:outlet] || [self isHorizontalLineOutlet:outlet]) {
        [mutString appendFormat:@"self.%@.keepHorizontalInsets.equal = 16;\n", outlet.name];
    } else {
        [mutString appendFormat:@"self.%@.keepHorizontalCenter.equal = 0.5;\n", outlet.name];
    }
    return [mutString copy];
}

-(NSString *)produceConstructorMacros {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"#pragma mark - Constructors macros -\n"];
    
    [_outlets each:^(NBOutletData *outlet) {
        NSString *string = [self constructorMacroWithOutlet:outlet];
        [mutString appendString:string];
        [mutString appendString:@"\n"];
    }];
    
    return [mutString copy];
}

-(NSString *)produceConstructorMethods {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"#pragma mark - Constructors -\n"];
    
    [_outlets each:^(NBOutletData *outlet) {
        NSString *string = [self constructorMethodWithOutlet:outlet];
        [mutString appendString:string];
        [mutString appendString:@"\n"];
    }];
    
    return [mutString copy];
}

-(NSString *)produceConstructorHelperMethods {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"#pragma mark - Constructor helper methods -\n"];
    
    [_outlets each:^(NBOutletData *outlet) {
        NSString *string = [self constructorHelperMethodWithOutlet:outlet];
        if (string.length > 0) {
            [mutString appendString:string];
            [mutString appendString:@"\n"];
        }
    }];

    return [mutString copy];
}

-(NSString *)produceActionMethods {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"#pragma mark - Actions -\n"];
    
    [_outlets each:^(NBOutletData *outlet) {
        NSString *string = [self actionMethodWithOutlet:outlet];
        if (string.length > 0) {
            [mutString appendString:string];
            [mutString appendString:@"\n"];
        }
    }];
    
    return [mutString copy];
}

-(NSString *)produceDelegateNotificationMethods {
    NSMutableString *mutString = [NSMutableString new];
    [mutString appendString:@"#pragma mark - Delegate notification methods -\n"];
    
    [_outlets each:^(NBOutletData *outlet) {
        NSString *string = [self delegateNotificationMethodWithOutlet:outlet];
        if (string.length > 0) {
            [mutString appendString:string];
            [mutString appendString:@"\n"];
        }
    }];
    
    return [mutString copy];
}

//-(NSString *)ivarNameWithOutlet:(NBOutletData *)outlet {
//    NSString *name = [NSString stringWithFormat:@"_%@", outlet.name];
//    return name;
//}

-(NSString *)firstLineInConstructorMethodWithOutlet:(NBOutletData *)outlet {
    if ([self isLabelOutlet:outlet]) {
        return [self labelFirstLineInConstructorMethodWithOutlet:outlet];
    } else if ([self isButtonOutlet:outlet]) {
        return [self buttonFirstLineInConstructorMethodWithOutlet:outlet];
    } else if ([self isImageViewOutlet:outlet]) {
        return [self imageViewFirstLineInConstructorMethodWithOutlet:outlet];
    } else {
        return nil;
    }
}

-(NSString *)labelFirstLineInConstructorMethodWithOutlet:(NBOutletData *)outlet {
    NSString *methodName = [self labelConstructorHelperMethodNameWithOutlet:outlet];
    return [NSString stringWithFormat:@"NSString *text = [self %@];\n",  methodName];
}

-(NSString *)buttonFirstLineInConstructorMethodWithOutlet:(NBOutletData *)outlet {
    NSString *methodName = [self buttonConstructorHelperMethodNameWithOutlet:outlet];
    return [NSString stringWithFormat:@"NSString *title = [self %@];\n",  methodName];
}

-(NSString *)imageViewFirstLineInConstructorMethodWithOutlet:(NBOutletData *)outlet {
    NSString *methodName = [self imageViewConstructorHelperMethodNameWithOutlet:outlet];
    return [NSString stringWithFormat:@"NSString *name = [self %@];\n",  methodName];
}

-(NSString *)constructorMacroWithOutlet:(NBOutletData *)outlet {
    NSString *constructorName = [self constructorMethodNameWithOutlet:outlet];
    
    NSString *line = [NSString stringWithFormat:@"CONSTRUCTOR_METHOD(%@, %@, %@)", outlet.className, outlet.name, constructorName];
    return line;
}

-(NSString *)constructorMethodNameWithOutlet:(NBOutletData *)outlet {
    NSString *capitalizedString = [self capitalizedString:outlet.name];
    
    NSString *name = [NSString stringWithFormat:@"new%@", capitalizedString];
    return name;
}

-(NSString *)capitalizedString:(NSString *)outletName {
    NSString *firstCapChar = [[outletName substringToIndex:1] capitalizedString];
    NSString *capitalizedString = [outletName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];

    return capitalizedString;
}

-(NSString *)constructorMethodWithOutlet:(NBOutletData *)outlet {
    NSMutableString *mutString = [NSMutableString new];

    NSString *constructorMethodName = [self constructorMethodNameWithOutlet:outlet];
    NSString *localVariableName = [self localVariableNameWithOutlet:outlet];
    NSString *constructorString = [self constructorWithOutlet:outlet];
    NSString *firstLine = [self firstLineInConstructorMethodWithOutlet:outlet];
    
    [mutString appendFormat:@"-(%@ *)%@ {\n", outlet.className, constructorMethodName];
    if (firstLine) {
        [mutString appendString:firstLine];
    }
    [mutString appendFormat:@"%@ *%@ = %@;\n", outlet.className, localVariableName, constructorString];
    [mutString appendFormat:@"return %@;\n", localVariableName];
    [mutString appendString:@"}\n"];
    return [mutString copy];
}

-(NSString *)constructorWithOutlet:(NBOutletData *)outlet {
    if ([self isLabelOutlet:outlet]) {
        return [self labelConstructorWithOutlet:outlet];
    } else if ([self isButtonOutlet:outlet]) {
        BOOL shouldAddSelector = [self isViewController];
        return [self buttonConstructorWithOutlet:outlet shouldAddSelector:shouldAddSelector];
    } else if ([self isImageViewOutlet:outlet]) {
        return [self imageViewConstructorWithOutlet:outlet];
    } else {
        return [self genericConstructorWithOutlet:outlet];
    }
}

-(NSString *)localVariableNameWithOutlet:(NBOutletData *)outlet {
    if ([self isLabelOutlet:outlet]) {
        return @"label";
    } else if ([self isButtonOutlet:outlet]) {
        return @"button";
    } else {
        return @"view";
    }
}

-(NSString *)genericConstructorWithOutlet:(NBOutletData *)outlet {
    return [NSString stringWithFormat:@"[%@ new]", outlet.className];
}

-(BOOL)isLabelOutlet:(NBOutletData *)outlet {
    return [outlet.className isEqualToString:@"UILabel"] || [outlet.name hasSuffix:@"Label"];
}

-(NSString *)labelConstructorWithOutlet:(NBOutletData *)outlet {
    NSString *string = [NSString stringWithFormat:@"[COUIHelper newLabelWithText:text fontSize:16]"];
    return string;
}

-(BOOL)isButtonOutlet:(NBOutletData *)outlet {
    return [outlet.className isEqualToString:@"UIButton"] || [outlet.name hasSuffix:@"Button"];
}

-(BOOL)isImageViewOutlet:(NBOutletData *)outlet {
    return [outlet.className isEqualToString:@"UIImageView"] || [[outlet.name lowercaseString] hasSuffix:@"imageview"];
}

-(BOOL)isHorizontalLineOutlet:(NBOutletData *)outlet {
    return [outlet.className isEqualToString:@"UIView"] && [outlet.name hasPrefix:@"horizontalLine"];
}

-(BOOL)isPopupClass {
    return [_className hasSuffix:@"Popup"];
}

-(NSString *)buttonConstructorWithOutlet:(NBOutletData *)outlet shouldAddSelector:(BOOL)shouldAddSelector {
    NSString *selector = [NSString stringWithFormat:@"@selector(%@)", [self buttonActionNameWithOutlet:outlet]];
    NSString *target = (shouldAddSelector ? @"self" : @"nil");
    NSString *action = (shouldAddSelector ? selector : @"nil");
    NSString *string = [NSString stringWithFormat:@"[COUIHelper newBlueButtonWithTitle:title target:%@ action:%@]", target, action];
    return string;
}

-(NSString *)imageViewConstructorWithOutlet:(NBOutletData *)outlet {
    return @"[UIImageView imageViewWithImageNamed:name]";
}

-(NSString *)constructorHelperMethodWithOutlet:(NBOutletData *)outlet {
    if ([self isLabelOutlet:outlet]) {
        return [self labelConstructorHelperMethodWithOutlet:outlet];
    } else if ([self isButtonOutlet:outlet]) {
        return [self buttonConstructorHelperMethodWithOutlet:outlet];
    } else if ([self isImageViewOutlet:outlet]) {
        return [self imageViewConstructorHelperMethodWithOutlet:outlet];
    } else {
        return nil;
    }
}

-(NSString *)labelConstructorHelperMethodNameWithOutlet:(NBOutletData *)outlet {
    return [NSString stringWithFormat:@"%@Text", outlet.name];
}

-(NSString *)labelConstructorHelperMethodWithOutlet:(NBOutletData *)outlet {
    NSMutableString *mutString = [NSMutableString new];

    NSString *methodName = [self labelConstructorHelperMethodNameWithOutlet:outlet];
    NSString *localizableKey = [self localizableKeyWithOutlet:outlet];
    [mutString appendFormat:@"-(NSString *)%@ {\n", methodName];
    [mutString appendFormat:@"return COString(@\"%@\");\n", localizableKey];
    [mutString appendString:@"}\n"];

    return [mutString copy];
}

-(NSString *)buttonConstructorHelperMethodNameWithOutlet:(NBOutletData *)outlet {
    return [NSString stringWithFormat:@"%@Title", outlet.name];
    
}

-(NSString *)buttonConstructorHelperMethodWithOutlet:(NBOutletData *)outlet {
    NSMutableString *mutString = [NSMutableString new];
    
    NSString *methodName = [self buttonConstructorHelperMethodNameWithOutlet:outlet];
    NSString *localizableKey = [self localizableKeyWithOutlet:outlet];

    [mutString appendFormat:@"-(NSString *)%@ {\n", methodName];
    [mutString appendFormat:@"return COString(@\"%@\");\n", localizableKey];
    [mutString appendString:@"}\n"];
    
    return [mutString copy];
}

-(NSString *)imageViewConstructorHelperMethodNameWithOutlet:(NBOutletData *)outlet {
    return [NSString stringWithFormat:@"%@Name", outlet.name];
    
}

-(NSString *)imageViewConstructorHelperMethodWithOutlet:(NBOutletData *)outlet {
    NSMutableString *mutString = [NSMutableString new];
    
    NSString *methodName = [self imageViewConstructorHelperMethodNameWithOutlet:outlet];
    
    [mutString appendFormat:@"-(NSString *)%@ {\n", methodName];
    [mutString appendString:@"return @\"\";\n"];
    [mutString appendString:@"}\n"];
    
    return [mutString copy];
}

-(NSString *)actionMethodWithOutlet:(NBOutletData *)outlet {
    if ([self isButtonOutlet:outlet]) {
        return [self buttonActionMethodWithOutlet:outlet shouldCallNotifyDelegateMethod:YES];
    } else {
        return nil;
    }
}

-(NSString *)delegateNotificationMethodWithOutlet:(NBOutletData *)outlet {
    if ([self isButtonOutlet:outlet]) {
        return [self buttonDelegateNotificationMethodWithOutlet:outlet];
    } else {
        return nil;
    }
}

-(NSString *)actionPlainNameWithOutlet:(NBOutletData *)outlet {
    return [outlet.name stringByReplacingOccurrencesOfString:@"Button" withString:@""];
}

-(NSString *)buttonActionNameWithOutlet:(NBOutletData *)outlet {
    return [outlet.name stringByReplacingOccurrencesOfString:@"Button" withString:@"Action:"];
}

-(NSString *)buttonActionMethodWithOutlet:(NBOutletData *)outlet shouldCallNotifyDelegateMethod:(BOOL)shouldCallNotifyDelegateMethod {
    
    NSMutableString *mutString = [NSMutableString new];
    NSString *buttonActionName = [self buttonActionNameWithOutlet:outlet];
    
    [mutString appendFormat:@"-(IBAction)%@(id)sender {\n", buttonActionName];
    
    if (shouldCallNotifyDelegateMethod) {
        NSString *delegateNotificationName = [self buttonDelegateNotificationNameWithOutlet:outlet];
        NSString *format = @"[self %@];\n";
        NSString *delegateNotificationCall = [NSString stringWithFormat:format, delegateNotificationName];
        [mutString appendString:delegateNotificationCall];
    }
    
    [mutString appendString:@"}\n"];
    
    return [mutString copy];
}

-(NSString *)delegateMethodWithOutlet:(NBOutletData *)outlet {
    if ([self isButtonOutlet:outlet]) {
        return [self buttonDelegateMethodWithOutlet:outlet];
    } else {
        return nil;
    }
}

-(NSString *)buttonDelegateNotificationMethodWithOutlet:(NBOutletData *)outlet {
    
    NSMutableString *mutString = [NSMutableString new];
    NSString *buttonDelegateNotificationName = [self buttonDelegateNotificationNameWithOutlet:outlet];
    
    [mutString appendFormat:@"-(void)%@ {\n", buttonDelegateNotificationName];
    NSString *buttonDelegateMethodName = [self buttonDelegateMethodNameWithOutlet:outlet];
    NSString *line1format = @"if ([self.delegate respondsToSelector:@selector(%@:)]) {\n";
    NSString *line2format = @"[self.delegate %@:self];\n";

    NSString *line1 = [NSString stringWithFormat:line1format, buttonDelegateMethodName];
    NSString *line2 = [NSString stringWithFormat:line2format, buttonDelegateMethodName];

    [mutString appendString:line1];
    [mutString appendString:line2];
    [mutString appendString:@"}\n"];
    [mutString appendString:@"}\n"];
    
    return [mutString copy];
}

-(NSString *)buttonDelegateNotificationNameWithOutlet:(NBOutletData *)outlet {
    // notifyDelegateDidSelectAction
    NSString *actionName = [self capitalizedString:[self actionPlainNameWithOutlet:outlet]];
    
    NSString *format = @"notifyDelegateDidSelect%@";
    NSString *name = [NSString stringWithFormat:format, actionName];
    return name;
}

-(NSString *)buttonDelegateMethodWithOutlet:(NBOutletData *)outlet {
    NSString *format = @"-(void)%@:(%@ *)vc;";
    NSString *delegateMethodName =[self buttonDelegateMethodNameWithOutlet:outlet];
    return [NSString stringWithFormat:format, delegateMethodName, self.className];
}

-(NSString *)buttonDelegateMethodNameWithOutlet:(NBOutletData *)outlet {
    NSString *format = @"%@DidSelect%@";
    NSString *classNameWithLowercasePrefix =[self classNameWithLowercaseOrganizationPrefix];
    NSString *actionName = [self capitalizedString:[self actionPlainNameWithOutlet:outlet]];
    return [NSString stringWithFormat:format, classNameWithLowercasePrefix, actionName];
}

-(BOOL)isView {
    return [_className hasSuffix:@"View"] || [_className hasSuffix:@"Popup"];
}

-(BOOL)isViewController {
    return [_className hasSuffix:@"ViewController"] || [_className hasSuffix:@"VC"];
}

-(NSString *)localizableKeyWithOutlet:(NBOutletData *)outlet {
    NSMutableString *mutString = [NSMutableString new];
    NSString *className = [self classNameForLocalization];
    NSString *outletClassName = [self outletClassNameForLocalizableKeyWithOutlet:outlet];
    NSString *outletName = [self outletNameForLocalizableKeyWithOutlet:outlet];
    NSString *attributeName = [self attributeNameForLocalizableKeyWithOutlet:outlet];
    
    if (_categoryName.length > 0) {
        [mutString appendString:_categoryName];
        [mutString appendString:@"."];
    }
    [mutString appendString:@"Screen."];
    [mutString appendString:className];
    [mutString appendString:@"."];
    [mutString appendString:outletClassName];
    [mutString appendString:@"."];
    [mutString appendString:outletName];
    [mutString appendString:@"."];
    [mutString appendString:attributeName];
    
    return [mutString copy];
}

-(NSString *)outletClassNameForLocalizableKeyWithOutlet:(NBOutletData *)outlet {
    if ([outlet.className hasPrefix:@"UI"]) {
        NSRange range = NSMakeRange(0, 2);
        NSString *string = [outlet.className stringByReplacingCharactersInRange:range withString:@""];
        return string;
    } else {
        return outlet.className;
    }
}

-(NSString *)outletNameForLocalizableKeyWithOutlet:(NBOutletData *)outlet {
    if ([outlet.name hasSuffix:@"Label"]) {
        NSString *string = [outlet.name stringByReplacingOccurrencesOfString:@"Label" withString:@""];
        return [self capitalizedString:string];
    } else if ([outlet.name hasSuffix:@"Button"]) {
        NSString *string = [outlet.name stringByReplacingOccurrencesOfString:@"Button" withString:@""];
        return [self capitalizedString:string];
    } else {
        return outlet.name;
    }
}

-(NSString *)attributeNameForLocalizableKeyWithOutlet:(NBOutletData *)outlet {
    if ([self isLabelOutlet:outlet]) {
        return @"Text";
    } else if ([self isButtonOutlet:outlet]) {
        return @"Title";
    } else {
        return @"";
    }
}

-(NSString *)classNameWithoutOrganizationPrefix {
    NSString *prefix = [self organizationPrefix];
    if ([self.className hasPrefix:prefix]) {
        NSRange range = NSMakeRange(0, prefix.length);
        return [self.className stringByReplacingCharactersInRange:range withString:@""];
    } else {
        return self.className;
    }
}

-(NSString *)classNameWithoutOrganizationPrefixAndClassSuffix {
    NSString *withoutPrefixString = [self classNameWithoutOrganizationPrefix];
    NSString *suffix = @"VC";
    if ([withoutPrefixString hasSuffix:suffix]) {
        NSRange range = NSMakeRange(withoutPrefixString.length-suffix.length, suffix.length);
        return [withoutPrefixString stringByReplacingCharactersInRange:range withString:@""];
    } else {
        return withoutPrefixString;
    }
}

-(NSString *)classNameWithLowercaseOrganizationPrefix {
    NSString *prefix = [self organizationPrefix];
    if ([self.className hasPrefix:prefix]) {
        NSString *lowercasePrefix = [prefix lowercaseString];
        NSRange range = NSMakeRange(0, prefix.length);
        return [self.className stringByReplacingCharactersInRange:range withString:lowercasePrefix];
    } else {
        return self.className;
    }
}

-(NSString *)organizationPrefix {
    return @"CO";
}

-(NSString *)classNameForLocalization {
    return [self classNameWithoutOrganizationPrefixAndClassSuffix];
}

-(BOOL)classHasButtons {
    return [self.outlets find:^BOOL(NBOutletData *outlet) {
        return [self isButtonOutlet:outlet];
    }] != nil;
}

-(NSString *)produceHeaderFile {
    NSMutableString *mutString = [NSMutableString new];
    if ([self classHasButtons]) {
        [mutString appendFormat:@"@class %@;\n\n", self.className];
        
        [mutString appendFormat:@"@protocol %@<NSObject>\n\n", self.protocolName];
        [self.outlets each:^(NBOutletData *outlet) {
            NSString *delegateMethod = [self delegateMethodWithOutlet:outlet];
            if (delegateMethod != nil) {
                [mutString appendString:delegateMethod];
                [mutString appendString:@"\n"];
            }
        }];
        [mutString appendString:@"\n"];
        [mutString appendString:@"@end\n\n"];
        
        [mutString appendFormat:@"@property(nonatomic, weak) id<%@> delegate;\n\n", self.protocolName];
    }
    return mutString.copy;
}

-(NSString *)protocolName {
    return [self.className stringByAppendingString:@"Delegate"];
}

@end
