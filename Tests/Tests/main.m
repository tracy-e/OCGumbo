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
         <body class='main' id=\"testID\"><select id=\"select\"> \
            <option class='abc efg'>A</option> \
            <option class='abc'>B</option> \
            <option >C</option> \
          </select> \
         <p> <div> <div> hello <div> </div>\
         <div> world </div> \
         </p> \
         <!-- comment --> \
         <title>\
         hello \
         </title> <select> \
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
        
        
        //Fetching from the website:
        NSLog(@"\n\n===============iOS Feed Info==================");
        NSString *iosfeedPage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.iosfeed.com"] encoding:NSUTF8StringEncoding error:nil];
        if (iosfeedPage) {
            OCGumboDocument *iosfeedDoc = [[OCGumboDocument alloc] initWithHTMLString:iosfeedPage];
            OCGumboNode *content = iosfeedDoc.Query(@".row").first();
            NSArray *rows = content.Query(@".media-body");
            for (OCGumboNode *row in rows) {
                OCGumboNode *title = row.Query(@"h2").children(@"a").first();
                NSLog(@"title:[%@](%@)", title.text(), title.attr(@"href"));
                
                OCGumboNode *link = row.Query(@"h2").find(@"small").children(@"a").first();
                NSLog(@"from:[%@](%@)",link.text(), link.attr(@"href"));
                
                NSLog(@"by %@ \n\n", row.Query(@"p").children(@"a").get(1).text());
            }
        }
    }
    return 0;
}

