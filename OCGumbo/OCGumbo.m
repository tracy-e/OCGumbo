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

#pragma mark C Methods

#if !defined(NS_INLINE)
    #define NS_INLINE static inline
#endif

static id OCGumboNodeCast(GumboNode *node);
static id OCGumboAttributeCast(GumboAttribute *attribute);

NS_INLINE GumboVector oc_gumbo_get_children(GumboNode *node) {
    if (node->type == GUMBO_NODE_DOCUMENT) {
        return node->v.document.children;
    }
    if (node->type == GUMBO_NODE_ELEMENT) {
        return node->v.element.children;
    }
    return kGumboEmptyVector;
}

NS_INLINE int oc_gumbo_get_child_cout(GumboNode *node) {
    return oc_gumbo_get_children(node).length;
}

NS_INLINE GumboTag oc_gumbo_get_tag(GumboNode *node) {
    return node->v.element.tag;
}

NS_INLINE const char *oc_gumbo_get_tagname(GumboNode *node) {
    if (node->type == GUMBO_NODE_ELEMENT) {
        return gumbo_normalized_tagname(node->v.element.tag);
    }
    return NULL;
}

NS_INLINE const char *oc_gumbo_get_attribute(GumboNode *node, const char *name) {
    if (node->type == GUMBO_NODE_ELEMENT) {
        GumboVector attributes = node->v.element.attributes;
        GumboAttribute *attribute = gumbo_get_attribute(&attributes, name);
        if (attribute) {
            return attribute->value;
        }
    }
    return NULL;
}

NS_INLINE int oc_gumbo_get_attribute_count(GumboNode *node) {
    if (node->type == GUMBO_NODE_ELEMENT) {
        return node->v.element.attributes.length;
    }
    return 0;
}

NS_INLINE GumboNode *oc_gumbo_get_child_at_index(GumboNode *node, int index) {
    return oc_gumbo_get_children(node).data[index];
}

NS_INLINE GumboNode *oc_gumbo_get_firstchild(GumboNode *node) {
    GumboVector children = oc_gumbo_get_children(node);
    if (children.length) {
        return children.data[0];
    }
    return NULL;
}

NS_INLINE GumboNode *oc_gumbo_get_lastchild(GumboNode *node) {
    GumboVector children = oc_gumbo_get_children(node);
    int length = children.length;
    if (length) {
        return children.data[length - 1];
    }
    return NULL;
}

NS_INLINE GumboNode *oc_gumbo_get_previoussibling(GumboNode *node) {
    GumboVector children = node->parent->v.element.children;
    int index = gumbo_vector_index_of(&children, node);
    if (index) {
        return children.data[index - 1];
    }
    return NULL;
}

NS_INLINE GumboNode *oc_gumbo_get_nextsibling(GumboNode *node) {
    GumboVector children = node->parent->v.element.children;
    int index = gumbo_vector_index_of(&children, node);
    if (index + 1 < children.length) {
        return children.data[index + 1];
    }
    return NULL;
}

NS_INLINE const char *oc_gumbo_get_text(GumboNode *node) {
    
    return nil;
}

NS_INLINE GumboNode *oc_gumbo_get_node_by_id(GumboNode *node, const char *Id) {
    GumboNode *root = NULL;
    if (node->type == GUMBO_NODE_DOCUMENT) {
        root = oc_gumbo_get_firstchild(node);
    } else {
        root = node;
    }
    
    int count = oc_gumbo_get_child_cout(root);
    for (int i = 0; i < count; i++) {
        GumboNode *child = oc_gumbo_get_child_at_index(root, i);
        if (child->type == GUMBO_NODE_ELEMENT) {
            const char *attributeValue = oc_gumbo_get_attribute(child, "id");
            if (attributeValue && !strcasecmp(Id, attributeValue)) {
                return child;
            } else {
                GumboNode *node = oc_gumbo_get_node_by_id(child, Id);
                if (node) {
                    return node;
                }
            }
        }
    }
    
    return NULL;
}

NS_INLINE GumboNode *oc_gumbo_get_node_by_tag(GumboNode *node, GumboTag tag) {
    GumboNode *root = NULL;
    if (node->type == GUMBO_NODE_DOCUMENT) {
        root = oc_gumbo_get_firstchild(node);
    } else {
        root = node;
    }
    
    int count = oc_gumbo_get_child_cout(root);
    for (int i = 0; i < count; i++) {
        GumboNode *child = oc_gumbo_get_child_at_index(root, i);
        if (child->type == GUMBO_NODE_ELEMENT) {
            if (oc_gumbo_get_tag(child) == tag) {
                return child;
            } else {
                GumboNode *node = oc_gumbo_get_node_by_tag(child, tag);
                if (node) {
                    return node;
                }
            }
        }
    }
    return NULL;
}

NS_INLINE NSArray *oc_gumbo_get_elements_by_tagname(GumboNode *node, const char *tagname) {
    NSMutableArray *nodeList = [[NSMutableArray alloc] init];
    GumboNode *root = NULL;
    if (node->type == GUMBO_NODE_DOCUMENT) {
        root = oc_gumbo_get_firstchild(node);
    } else {
        root = node;
    }
    
    int count = oc_gumbo_get_child_cout(root);
    for (int i = 0; i < count; i++) {
        GumboNode *child = oc_gumbo_get_child_at_index(root, i);
        if (child->type == GUMBO_NODE_ELEMENT) {
            if (!strcasecmp(oc_gumbo_get_tagname(child), tagname)) {
                [nodeList addObject:OCGumboNodeCast(child)];
            }
            NSArray *subNodeList = oc_gumbo_get_elements_by_tagname(child, tagname);
            if ([subNodeList count]) {
                [nodeList addObjectsFromArray:subNodeList];
            }
        }
    }
    return nodeList;
}


@implementation OCGumboNode

- (id)initWithGumboNode:(GumboNode *)node {
    self = [super init];
    if (self) {
        _gumboNode = node;
    }
    return self;
}

//TODO: When gumbo add the API for binding, this method is to update.
+ (id)nodeWithGumboNode:(GumboNode *)node {
    Class cls;
    if (node->type == GUMBO_NODE_DOCUMENT) {
        cls = [OCGumboDocument class];
    } else if (node->type == GUMBO_NODE_ELEMENT) {
        cls = [OCGumboElement class];
    } else {
        cls = [OCGumboText class];
    }
    return [[cls alloc] initWithGumboNode:node];
}

id OCGumboNodeCast(GumboNode *node) {
    return [OCGumboNode nodeWithGumboNode:node];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@>" ,[self class],self,
            self.nodeName ? self.nodeName : self.nodeValue];
}

#pragma mark - Properties
- (NSString *)nodeName {
    if (_gumboNode->type == GUMBO_NODE_DOCUMENT) {
        return @"#document";
    }
    if (_gumboNode->type == GUMBO_NODE_ELEMENT) {
        return @(oc_gumbo_get_tagname(_gumboNode));
    }
    if (_gumboNode->type == GUMBO_NODE_TEXT) {
        return @"#text";
    }
    return nil;
}

- (NSString *)nodeValue {
    GumboNodeType type = _gumboNode->type;
    if (type != GUMBO_NODE_DOCUMENT &&
        type != GUMBO_NODE_ELEMENT) {
        return @(_gumboNode->v.text.text);
    }
    return nil;
}

- (GumboNodeType)nodeType {
    return _gumboNode->type;
}

- (NSArray *)childNodes {
    NSMutableArray *childNodes = [[NSMutableArray alloc] init];
    GumboVector children = oc_gumbo_get_children(_gumboNode);
    for (int i = 0; i < children.length; i++) {
        GumboNode *child = children.data[i];
        [childNodes addObject:[OCGumboNode nodeWithGumboNode:child]];
    }
    return childNodes;
}

- (OCGumboNode *)parentNode {
    return [OCGumboNode nodeWithGumboNode:_gumboNode->parent];
}

- (OCGumboNode *)firstChild {
    GumboNode *node = oc_gumbo_get_firstchild(_gumboNode);
    return OCGumboNodeCast(node);
}

- (OCGumboNode *)lastChild {
    GumboNode *node = oc_gumbo_get_lastchild(_gumboNode);
    return OCGumboNodeCast(node);
}

- (OCGumboNode *)previousSibling {
    GumboNode *node = oc_gumbo_get_previoussibling(_gumboNode);
    return OCGumboNodeCast(node);
}

- (OCGumboNode *)nextSibling {
    GumboNode *node = oc_gumbo_get_nextsibling(_gumboNode);
    return OCGumboNodeCast(node);
}

@end

#pragma mark -
@implementation OCGumboElement

- (NSString *)tagName {
    return self.nodeName;
}

//TODO: Didn't find the right API to do this。
- (NSString *)innerHTML {
    printf("[%s]\n",_gumboNode->v.element.original_end_tag.data);
    return nil;
}

//TODO: Didn't find the right API to do this。
- (NSString *)innerText {
    return nil;
}

- (NSArray *)attributes {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    GumboVector attributes = _gumboNode->v.element.attributes;
    for (int i = 0; i < attributes.length; i++) {
        GumboAttribute *attribute = attributes.data[i];
        [result addObject:OCGumboAttributeCast(attribute)];
    }
    return result;
}

- (OCGumboAttribute *)getAttributeNode:(NSString *)name {
    return OCGumboAttributeCast(gumbo_get_attribute(&_gumboNode->v.element.attributes, [name UTF8String]));
}

- (NSString *)getAttribute:(NSString *)name {
    return @(oc_gumbo_get_attribute(_gumboNode, [name UTF8String]));
}

@end

#pragma mark -
@implementation OCGumboText

- (NSString *)data {
    return @(_gumboNode->v.text.text);
}

@end

#pragma mark -
@implementation OCGumboDocument {
    GumboOutput *_gumboOutput;
}

- (void)dealloc {
    gumbo_destroy_output(&kGumboDefaultOptions, _gumboOutput);
}

- (instancetype)initWithHTMLString:(NSString *)htmlString URL:(NSString *)URL {
    self = [super init];
    if (self) {
        _URL = URL;
        _gumboOutput = gumbo_parse([htmlString UTF8String]);
        _gumboNode = _gumboOutput->document;
    }
    return self;
}

#pragma mark - Properties
- (NSString *)title {
    GumboNode *node = oc_gumbo_get_node_by_tag(_gumboNode, GUMBO_TAG_TITLE);
    if (node && node->v.element.children.length) {
        GumboNode *text = node->v.element.children.data[0];
        if (text->type == GUMBO_NODE_TEXT) {
            return @(text->v.text.text);
        }
    }
    return nil;
}

- (OCGumboElement *)documentElement {
    return [OCGumboNode nodeWithGumboNode:_gumboOutput->root];
}

- (OCGumboElement *)head {
    GumboNode *node = oc_gumbo_get_node_by_tag(_gumboNode, GUMBO_TAG_HEAD);
    return OCGumboNodeCast(node);
}

- (OCGumboElement *)body {
    GumboNode *node = oc_gumbo_get_node_by_tag(_gumboNode, GUMBO_TAG_BODY);
    return OCGumboNodeCast(node);
}

#pragma mark - Methods
- (OCGumboElement *)getElementById:(NSString *)elementId {
    GumboNode *node = oc_gumbo_get_node_by_id(_gumboNode, [elementId UTF8String]);
    return OCGumboNodeCast(node);
}

- (NSArray *)getElementsByTagName:(NSString *)tagname {
    return oc_gumbo_get_elements_by_tagname(_gumboNode, [tagname UTF8String]);
}

@end

#pragma mark -
@implementation OCGumboAttribute {
    GumboAttribute *_gumboAttribute;
}

- (instancetype)initWithGumboAttribute:(GumboAttribute *)attribute {
    self = [super init];
    if (self) {
        _gumboAttribute = attribute;
    }
    return self;
}

+ (instancetype)attributeWithGumboAttribute:(GumboAttribute *)attribute {
    return [[OCGumboAttribute alloc] initWithGumboAttribute:attribute];
}

id OCGumboAttributeCast(GumboAttribute *attribute) {
    return [OCGumboAttribute attributeWithGumboAttribute:attribute];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@=%@>", [self class], self, self.name, self.value];
}

#pragma mark - Properties
- (NSString *)name {
    return @(_gumboAttribute->name);
}

- (NSString *)value {
    return @(_gumboAttribute->value);
}

@end