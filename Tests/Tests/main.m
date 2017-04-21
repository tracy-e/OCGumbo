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
#import "OCGumbo+Query.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        OCGumboDocument *document =
        [[OCGumboDocument alloc] initWithHTMLString:
         @"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> \
         <head> \
            <title>Hello OCGumbo</title> \
         </head> \
         <body class=\"main\" id=\"testID\"> \
            <select id=\"select\"> \
                <option class='abc efg'>A</option> \
                <option id=\"select\" class='abc'>B</option> \
                <option >C</option> \
            </select> \
            <div> \
                <div id=\"theId\"> hello <div> \
            </div>\
            <div class=\"theCls\">world</div> \
            <p>text in p</p>\
            <!-- comment --> \
            <select> \
                <option class='abc efg'>A</option> \
                <option class='abc'>B</option> \
                <option>C</option> \
            </select> \
         </body>\
         "];
    
        //Basic Usage:
        NSLog(@"\n==================Basic Usage=====================");
        NSLog(@"document:%@", document);
        NSLog(@"has doctype: %d", document.hasDoctype);
        NSLog(@"publicID: %@", document.publicID);
        NSLog(@"systemID:%@", document.systemID);
        NSLog(@"title:%@", document.title);
        NSLog(@"childNodes:%@", document.body.childNodes);
        NSLog(@"documentElement:%@", document.rootElement);
        NSLog(@"head:%@", document.head);
        NSLog(@"body:%@", document.body);

        //Extension Query:
        NSLog(@"\n\n===============Extension Query==================");
        NSLog(@"options: %@", document.Query(@"body").find(@"#select").find(@"option"));
        NSLog(@"title: %@", document.Query(@"title").text());
        NSLog(@"attribute: %@", document.Query(@"select").first().attr(@"id"));
        NSLog(@"class: %@", document.Query(@"#select").parents(@".main"));
        NSLog(@"tag.class: %@", document.Query(@"div.theCls"));
        NSLog(@"tag#id : %@", document.Query(@"div#theId"));
        
        //Fetching from the website:
        NSLog(@"\n\n=============== Web ==================");
        NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://github.com"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
        if (html) {
            OCGumboDocument *doc = [[OCGumboDocument alloc] initWithHTMLString:html];
            NSArray *images = doc.Query(@"img");
            for (OCGumboElement *img in images) {
                NSLog(@"%@", img.attributes);
            }
        }
    }
    return 0;
}

