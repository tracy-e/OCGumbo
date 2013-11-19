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

#import "OCGumbo+Query.h"

#pragma mark - C Methods

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

NS_INLINE void add_valid_node_to_array(GumboNode *node, NSString *selector, NSMutableArray *__autoreleasing *array) {
    //class selector (.clsname)
    if ([selector hasPrefix:@"."]) {
        GumboAttribute *classAttribute = gumbo_get_attribute(&node->v.element.attributes, "class");
        if (classAttribute) {
            NSArray *selectors = [@(classAttribute->value) componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([selectors containsObject:[selector substringFromIndex:1]]) {
                [*array addObject:OCGumboNodeCast(node)];
            }
        }
    }
    
    //id selector (#eleId)
    else if ([selector hasPrefix:@"#"]) {
        GumboAttribute *idAttribute = gumbo_get_attribute(&node->v.element.attributes, "id");
        if (idAttribute) {
            const char *elementId = idAttribute->value;
            if (!strcasecmp(elementId, [[selector substringFromIndex:1] UTF8String])) {
                [*array addObject:OCGumboNodeCast(node)];
            }
        }
    }
    
    //tag selector (p | p.clsname | p#eleId)
    else {
        NSString *tag = nil;
        NSUInteger classMark = [selector rangeOfString:@"."].location;
        NSUInteger idMark = [selector rangeOfString:@"#"].location;
        const char *tagname = gumbo_normalized_tagname(node->v.element.tag);
        
        if (classMark != NSNotFound) {
            tag = [selector substringToIndex:classMark];
            NSString *cls = [selector substringFromIndex:classMark + 1];
            const char *attrValue = oc_gumbo_get_attribute(node, "class");
            if (attrValue && !strcasecmp(tagname, [tag UTF8String])) {
                NSString *clsValue = @(attrValue);
                NSArray *values = [clsValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([values containsObject:cls]) {
                    [*array addObject:OCGumboNodeCast(node)];
                }
            }
        } else if (idMark != NSNotFound) {
            tag = [selector substringToIndex:idMark];
            NSString *Id = [selector substringFromIndex:idMark + 1];
            const char *attrValue = oc_gumbo_get_attribute(node, "id");
            if (attrValue &&
                !strcasecmp(tagname, [tag UTF8String]) &&
                !strcasecmp(attrValue, [Id UTF8String])) {
                [*array addObject:OCGumboNodeCast(node)];
            }
        } else {
            tag = selector;
            if (!strcasecmp(tagname, [tag UTF8String])) {
                [*array addObject:OCGumboNodeCast(node)];
            }
        }
    }
}

NS_INLINE NSArray *oc_gumbo_find_children(GumboNode *root, NSString *selector, bool deep) {
    NSMutableArray *result = [NSMutableArray array];
    GumboVector children = kGumboEmptyVector;
    if (root->type == GUMBO_NODE_DOCUMENT) {
        children = root->v.document.children;
    } else if (root->type == GUMBO_NODE_ELEMENT){
        children = root->v.element.children;
    }
    for (int i = 0; i < children.length; i++) {
        GumboNode *child = children.data[i];
        if (selector && selector.length) {
            if (child->type == GUMBO_NODE_ELEMENT) {
                 add_valid_node_to_array(child, selector, &result);
                if (deep) {
                    NSArray *subList = oc_gumbo_find_children(child, selector, deep);
                    if (subList && [subList count]) {
                        [result addObjectsFromArray:subList];
                    }
                }
            }
        } else {
            [result addObject:OCGumboNodeCast(child)];
        }
    }
    return result;
}

NS_INLINE NSArray *oc_gumbo_find_parents(GumboNode *node, NSString *selector, BOOL deep) {
    NSMutableArray *result = [NSMutableArray array];
    
    GumboNode *parent = node->parent;
    while (parent) {
        if (parent->type == GUMBO_NODE_ELEMENT) {
            add_valid_node_to_array(parent, selector, &result);
            if (deep) {
                NSArray *subList = oc_gumbo_find_children(parent, selector, deep);
                if (subList && [subList count]) {
                    [result addObjectsFromArray:subList];
                }
            }
        }
        parent = parent->parent;
    }
    
    return result;
}

#pragma mark -

@implementation OCGumboNode (Query)

- (OCGumboQueryBlockAS)Query {
    OCGumboQueryBlockAS block = ^ id (NSString *selector) {
        return oc_gumbo_find_children(self->_gumboNode, selector, true);
    };
    return block;
}

- (OCGumboQueryBlockSV)text {
    OCGumboQueryBlockSV block = ^ NSString *(void) {
        NSMutableString *result = [NSMutableString string];
        if (self.nodeType == GUMBO_NODE_DOCUMENT || self.nodeType == GUMBO_NODE_ELEMENT) {
            NSString *text = self.Query(nil).text();
            if (text && text.length) {
                [result appendString:text];
            }
        } else if(self.nodeType == GUMBO_NODE_TEXT){
            [result appendString:self.nodeValue];
        }

        return result;
    };
    return block;
}

//may be not a fully reliable implementation.
- (OCGumboQueryBlockSV)html {
    OCGumboQueryBlockSV block = ^ NSString *(void) {
        if (self.nodeType == GUMBO_NODE_ELEMENT) {
            GumboElement *element = &self->_gumboNode->v.element;
            NSString *result = @(element->original_tag.data);
            NSString *originalEndTag = @(element->original_end_tag.data);
            result = [result stringByReplacingCharactersInRange:NSMakeRange(result.length - originalEndTag.length, originalEndTag.length) withString:@""];
            NSUInteger start = [result rangeOfString:@">"].location;
            if (start != NSNotFound) {
                result = [result substringFromIndex:start + 1];
            }
            return result;
        } else {
            return nil;
        }
    };
    return block;
}


- (OCGumboQueryBlockSS)attr {
    OCGumboQueryBlockSS block = ^ NSString *(NSString *name) {
        if (self->_gumboNode->type == GUMBO_NODE_ELEMENT) {
            GumboAttribute *attribute = gumbo_get_attribute(&self->_gumboNode->v.element.attributes, [name UTF8String]);
            if (attribute) {
                return @(attribute->value);
            }
        }
        return nil;
    };
    return block;
}

@end


#pragma mark -

@implementation NSArray (Query)

- (NSArrayQueryBlockSV)text {
    NSArrayQueryBlockSV block = ^ NSString *(void) {
        NSMutableString *result = [NSMutableString string];
        for (OCGumboNode *node in self) {
            if (node.nodeType == GUMBO_NODE_DOCUMENT || node.nodeType == GUMBO_NODE_ELEMENT) {
                NSString *text = node.childNodes.text();
                if (text && text.length) {
                    [result appendString:text];
                }
            } else if(node.nodeType == GUMBO_NODE_TEXT){
                [result appendString:node.nodeValue];
            }
        }
        return result;
    };
    return block;
}

- (NSArrayQueryBlockNV)first {
    NSArrayQueryBlockNV block = ^ OCGumboNode *(void) {
        if ([self count]) {
            return self[0];
        }
        return nil;
    };
    return block;
}

- (NSArrayQueryBlockNV)last {
    NSArrayQueryBlockNV block = ^ OCGumboNode *(void) {
        return [self lastObject];
    };
    return block;
}

- (NSArrayQueryBlockNI)get {
    NSArrayQueryBlockNI block = ^ OCGumboNode *(NSUInteger index) {
        if (index < [self count]) {
            return self[index];
        }
        return nil;
    };
    return block;
}

- (NSArrayQueryBlockBS)hasClass {
    NSArrayQueryBlockBS block = ^ BOOL (NSString *name) {
       
        return NO;
    };
    return block;
}

- (NSArrayQueryBlockIN)index {
    NSArrayQueryBlockIN block = ^ NSUInteger (OCGumboNode *child) {
        return [self indexOfObject:child];
    };
    return block;
}

- (NSArrayQueryBlockAS)find {
    NSArrayQueryBlockAS block = ^ OCQueryObject *(NSString *selector) {
        NSMutableArray *result = [NSMutableArray array];
        for (OCGumboNode *child in self) {
            NSArray *nodes = oc_gumbo_find_children(child->_gumboNode, selector, true);
            if (nodes && [nodes count]) {
                [result addObjectsFromArray:nodes];
            }
        }
        return (OCQueryObject *)result;
    };
    return block;
}

- (NSArrayQueryBlockAS)children {
    NSArrayQueryBlockAS block = ^ OCQueryObject *(NSString *selector) {
        NSMutableArray *result = [NSMutableArray array];
        for (OCGumboNode *child in self) {
            NSArray *nodes = oc_gumbo_find_children(child->_gumboNode, selector, false);
            if (nodes && [nodes count]) {
                [result addObjectsFromArray:nodes];
            }
        }
        return (OCQueryObject *)result;
    };
    return block;
}


- (NSArray *)_filterArray {
    NSMutableArray *result = [NSMutableArray array];
    for (OCGumboNode *node in self) {
        if (![result containsObject:node]) {
            [result addObject:node];
        }
    }
    return result;
}

- (NSArrayQueryBlockAS)parent {
    NSArrayQueryBlockAS block = ^ OCQueryObject *(NSString *selector) {
        NSMutableArray *result = [NSMutableArray array];
        for (OCGumboNode *child in self) {
            NSArray *nodes = oc_gumbo_find_parents(child->_gumboNode, selector, false);
            if (nodes && [nodes count]) {
                [result addObjectsFromArray:nodes];
            }
        }
        return (OCQueryObject *)[result _filterArray];
    };
    return block;
}

- (NSArrayQueryBlockAS)parents {
    NSArrayQueryBlockAS block = ^ OCQueryObject *(NSString *selector) {
        NSMutableArray *result = [NSMutableArray array];
        for (OCGumboNode *child in self) {
            NSArray *nodes = oc_gumbo_find_parents(child->_gumboNode, selector, true);
            if (nodes && [nodes count]) {
                [result addObjectsFromArray:nodes];
            }
        }
        return (OCQueryObject *)[result _filterArray];
    };
    return block;
}

@end
