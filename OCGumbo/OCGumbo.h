//  Copyright [2013] tracy.cpp@gmail.com (TracyYih)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#if !__has_feature(objc_arc)
    #error OCGumbo must be built with ARC.
#endif

#include "gumbo.h"

@interface OCGumboNode : NSObject {
    GumboNode *_gumboNode;
}

@property (nonatomic, copy, readonly) NSString *nodeName;
@property (nonatomic, copy, readonly) NSString *nodeValue;
@property (nonatomic, readonly) GumboNodeType   nodeType;

@property (nonatomic, readonly) NSArray *childNodes;
@property (nonatomic, readonly) OCGumboNode *parentNode;
@property (nonatomic, readonly) OCGumboNode *firstChild;
@property (nonatomic, readonly) OCGumboNode *lastChild;
@property (nonatomic, readonly) OCGumboNode *previousSibling;
@property (nonatomic, readonly) OCGumboNode *nextSibling;

@end

@class OCGumboAttribute;
@interface OCGumboElement : OCGumboNode

@property (nonatomic, copy, readonly) NSString *tagName;
@property (nonatomic, copy, readonly) NSString *innerHTML;
@property (nonatomic, copy, readonly) NSString *innerText;

@property (nonatomic, readonly) NSArray *attributes;

- (NSString *)getAttribute:(NSString *)name;
- (OCGumboAttribute *)getAttributeNode:(NSString *)name;

@end

@interface OCGumboText : OCGumboNode

@property (nonatomic, copy, readonly) NSString *data;

@end

@interface OCGumboDocument : OCGumboNode

@property (nonatomic, copy, readonly) NSString *URL;
@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, readonly) BOOL hasDoctype;
@property (nonatomic, copy, readonly) NSString *publicID;
@property (nonatomic, copy, readonly) NSString *systemID;

@property (nonatomic, readonly) OCGumboElement *documentElement;
@property (nonatomic, readonly) OCGumboElement *head;
@property (nonatomic, readonly) OCGumboElement *body;

- (instancetype)initWithHTMLString:(NSString *)htmlString URL:(NSString *)URL;

- (OCGumboElement *)getElementById:(NSString *)elementId;
- (NSArray *)getElementsByTagName:(NSString *)tagname;

@end

@interface OCGumboAttribute : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *value;

@end