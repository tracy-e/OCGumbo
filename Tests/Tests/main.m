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


#import <Foundation/Foundation.h>
#import "OCGumbo.h"
#import "OCGumbo+Query.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
                
        OCGumboDocument *document =
        [[OCGumboDocument alloc] initWithHTMLString:
         @"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> \
         <body id=\"testID\"><select id=\"select\"> \
            <option class='abc efg'>A</option> \
            <option class='abc'>B</option> \
            <option id='select'>C</option> \
          </select> \
         <p> <div> <div> hello <div> </div>\
         <div> world </div> \
         </p> \
         <!-- comment --> \
         <title>\
         hello \
         </title> <select id=\"select\"> \
         <option class='abc efg'>A</option> \
         <option class='abc'>B</option> \
         <option id='select'>C</option> \
         </select> \
         </body>\
         "];
    
        NSLog(@"Query: %@", document.Query(@"#testID"));
        
        NSArray *elements = document.Query(@"body");
        NSLog(@"%@", elements.find(@"option").parents(@"select"));
        
        NSLog(@"document:%@", document);
        NSLog(@"has doctype: %d", document.hasDoctype);
        NSLog(@"publicID: %@", document.publicID);
        NSLog(@"systemID:%@", document.systemID);
        NSLog(@"title:%@", document.title);
        NSLog(@"childNodes:%@", document.body.childNodes);
        
        NSLog(@"documentElement:%@", document.rootElement);
        NSLog(@"head:%@", document.head);
        NSLog(@"body:%@", document.body);
        
    }
    return 0;
}

