

/* Copyright (c) 2011, Peter Barrett  
**  
** Permission to use, copy, modify, and/or distribute this software for  
** any purpose with or without fee is hereby granted, provided that the  
** above copyright notice and this permission notice appear in all copies.  
** 
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL  
** WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED  
** WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR  
** BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES  
** OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,  
** WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,  
** ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS  
** SOFTWARE.  
*/

#include "USBAPI.h"
#include "PluggableUSB.h"

#if defined(USBCON)
#ifdef PLUGGABLE_USB_ENABLED

#define MAX_MODULES	6

static u8 startIf = CDC_ACM_INTERFACE + CDC_INTERFACE_COUNT;
static u8 firstEp = CDC_FIRST_ENDPOINT + CDC_ENPOINT_COUNT;

static u8 lastIf = startIf;
static u8 lastEp = firstEp;

PUSBCallbacks* cbs[MAX_MODULES];
u8 modules_count = 0;

int PUSB_GetInterface(u8* interfaceNum)
{
	for (u8 i=0; i<MAX_MODULES; i++) {
		cbs[i]->getInterface(interfaceNum);
	}
}

int PUSB_GetDescriptor(int t)
{
	for (u8 i=0; i<MAX_MODULES; i++) {
		cbs[i]->getDescriptor(interfaceNum);
	}
}

bool PUSB_Setup(Setup& setup, u8 j)
{
	for (u8 i=0; i<MAX_MODULES; i++) {
		cbs[i]->setup(interfaceNum, j);
	}
}

int PUSBaddFunction(PUSBCallbacks *cb, PUSBReturn *ret) 
{
	if (modules_count >= MAX_MODULES) {
		return 0;
	}
	cbs[modules_count] = cb;

	ret.interfaceNum = lastIf;
	ret.firstEndpoint = lastEp;
	lastIf++;
	for ( u8 i = 0; i< cb->numEndpoints; i++) {
		_initEndpoints[lastEp] = cb->endpointType[i];
		lastEp++;
	}
	modules_count++;
	// restart USB layer???
}

#endif

#endif /* if defined(USBCON) */