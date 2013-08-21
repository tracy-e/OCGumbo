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

#import "OCGumbo.h"

@class OCQueryObject;
typedef OCQueryObject * (^OCGumboQueryBlockAS) (NSString *);
typedef NSString *      (^OCGumboQueryBlockSS) (NSString *);
typedef NSString *      (^OCGumboQueryBlockSV) (void);

@interface OCGumboNode (Query)

//node.Query(selector);
@property (nonatomic, weak, readonly) OCGumboQueryBlockAS Query;

//element.attr(attributeName);
@property (nonatomic, weak, readonly) OCGumboQueryBlockSS attr;

@end


typedef OCGumboNode *   (^NSArrayQueryBlockNV) (void);
typedef OCGumboNode *   (^NSArrayQueryBlockNI) (NSUInteger);
typedef BOOL            (^NSArrayQueryBlockBS) (NSString *);
typedef NSUInteger      (^NSArrayQueryBlockIN) (OCGumboNode *);
typedef OCQueryObject * (^NSArrayQueryBlockAS) (NSString *);
typedef NSString *      (^NSArrayQueryBlockSV) (void);

@protocol OCQueryObject <NSObject>



@end
@interface OCQueryObject : NSArray

//nodelist.text();
@property (nonatomic, weak, readonly) NSArrayQueryBlockSV text;

//nodeList.first();
@property (nonatomic, weak, readonly) NSArrayQueryBlockNV first;

//nodeList.last();
@property (nonatomic, weak, readonly) NSArrayQueryBlockNV last;

//nodeList.get(2);
@property (nonatomic, weak, readonly) NSArrayQueryBlockNI get;

//nodeList.hasClass(name);
@property (nonatomic, weak, readonly) NSArrayQueryBlockBS hasClass;

//nodeList.index(node);
@property (nonatomic, weak, readonly) NSArrayQueryBlockIN index;

//nodeList.find(selector);
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS find;

//nodeList.children(selector);
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS children;

//nodeList.parent(selector);
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS parent;

//nodeList.parents(selector);
@property (nonatomic, weak, readonly) NSArrayQueryBlockAS parents;


@end