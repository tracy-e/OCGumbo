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

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        OCGumboDocument *document =
        [[OCGumboDocument alloc] initWithHTMLString:
         @"<body><select id=\"select\"> \
            <option>A</option> \
            <option>B</option> \
            <option id='select'>C</option> \
          </select> \
         <p> <div> <div> hello <div> </div>\
         <div> world </div> \
         </p> \
         <!-- comment --> \
         <title>\
         hello \
         </title> </body>\
         " URL:@"http://esoftmobile.com"];
        
        NSLog(@"document:%@", document);
        NSLog(@"URL:%@", document.URL);
        NSLog(@"title:%@", document.title);
        NSLog(@"childNodes:%@", document.body.childNodes);
        
        NSLog(@"documentElement:%@", document.documentElement);
        NSLog(@"head:%@", document.head);
        NSLog(@"body:%@", document.body);
        NSLog(@"getElementById:%@", [[document getElementById:@"select"] getAttributeNode:@"id"]);
        NSLog(@"getElementsByTagName:%@", [document getElementsByTagName:@"div"]);
    }
    return 0;
}

