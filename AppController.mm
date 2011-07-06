// ----------------------------------------------------------------------------
// Copyright (c) 2008 Karl Pitrich. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation 
//   and/or other materials provided with the distribution.
// * Neither the name of the <ORGANIZATION> nor the names of its contributors 
//   may be used to endorse or promote products derived from this software without 
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
// OF SUCH DAMAGE.
//
// Initial Author: Karl Pitrich <pit@paperium.com>
// Revision $Id$
// ----------------------------------------------------------------------------

#import "AppController.h"
#include <IOKit/graphics/IOGraphicsLib.h>
#include <ApplicationServices/ApplicationServices.h>

// ----------------------------------------------------------------------------

enum {
  // from <IOKit/graphics/IOGraphicsTypesPrivate.h>
  kIOFBSetTransform = 0x00000400,
};

// ----------------------------------------------------------------------------

static IOOptionBits anglebits[] = {
  (kIOFBSetTransform | (kIOScaleRotate0)   << 16),
  (kIOFBSetTransform | (kIOScaleRotate90)  << 16),
  (kIOFBSetTransform | (kIOScaleRotate180) << 16),
  (kIOFBSetTransform | (kIOScaleRotate270) << 16)
};

// ----------------------------------------------------------------------------

@implementation AppController

// ----------------------------------------------------------------------------

- init
{
  self = [super init];
  return self;
}

// ----------------------------------------------------------------------------

- (void) awakeFromNib
{ 
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
  [statusItem setTitle:@"0°"];
  [statusItem setMenu:statusMenu];
	[statusItem setToolTip:@"Rotate Screen"];
	[statusItem setHighlightMode:YES];
  
  [self rotateScreen:0];
}

// ----------------------------------------------------------------------------

- (void) dealloc 
{
	[statusItem release];
	[statusMenu release];
  [super dealloc];
}

// ----------------------------------------------------------------------------

- (IBAction)quit:(id)sender
{
  [NSApp terminate:self];
}

// ----------------------------------------------------------------------------

- (void) rotateScreen:(long)angle
{
  CGDirectDisplayID targetDisplay = CGMainDisplayID();
  IOOptionBits options;
      
  if ((angle % 90) != 0) { // map arbitrary angles to a rotation reset
    options = anglebits[0];
  }
  else {
    options = anglebits[(angle / 90) % 4];
  }
  
  // get I/O Kit service port of the target display.
  // the port is owned by the graphics system -> do not destroy it
  io_service_t service = CGDisplayIOServicePort(targetDisplay);
  
  // check if target display supports kIOFBSetTransform
  CGDisplayErr err = IOServiceRequestProbe(service, options);
  if (err != kCGErrorSuccess) {
    NSLog(@"IOServiceRequestProbe: error %d\n", err);
  }
}

// ----------------------------------------------------------------------------

- (IBAction)rotateScreenMenu:(id)sender
{  
  for (int m = 0; m < [statusMenu numberOfItems] - 1; m++) {
    [[statusMenu itemAtIndex:m] setState:NSOffState];
  }
  
  [sender setState:NSOnState];
  
  switch ([statusMenu indexOfItem:sender]) {
    case 1:
      [self rotateScreen:90];
      [statusItem setTitle:@"90°"];
      break;
    case 2:
      [self rotateScreen:180];
      [statusItem setTitle:@"180°"];
      break;
    case 3:
      [self rotateScreen:270];
      [statusItem setTitle:@"270°"];
      break;
    default:
    case 0:
      [self rotateScreen:0];
      [statusItem setTitle:@"0°"];
      break;
  }
}

// ----------------------------------------------------------------------------

@end

// ----------------------------------------------------------------------------