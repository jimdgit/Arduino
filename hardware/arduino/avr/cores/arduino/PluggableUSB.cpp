

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

static u8 lastIf = CDC_ACM_INTERFACE + CDC_INTERFACE_COUNT;
static u8 lastEp = CDC_FIRST_ENDPOINT + CDC_ENPOINT_COUNT;

extern u8 _initEndpoints[];

PUSBCallbacks cbs[MAX_MODULES];
u8 modules_count = 0;

int8_t PUSB_GetInterface(u8* interfaceNum)
{
	int8_t ret = 0;
	for (u8 i=0; i<modules_count; i++) {
		ret = cbs[i].getInterface(interfaceNum);
	}
	return ret;
}

int8_t PUSB_GetDescriptor(int8_t t)
{
	int8_t ret = 0;
	for (u8 i=0; i<modules_count && ret == 0; i++) {
		ret = cbs[i].getDescriptor(t);
	}
	return ret;
}

bool PUSB_Setup(Setup& setup, u8 j)
{
	bool ret = false;
	for (u8 i=0; i<modules_count && ret == false; i++) {
		ret = cbs[i].setup(setup, j);
	}
	return ret;
}

int8_t PUSB_AddFunction(PUSBCallbacks *cb, u8* interface) 
{
	if (modules_count >= MAX_MODULES) {
		return 0;
	}
	cbs[modules_count] = *cb;

	*interface = lastIf;
	lastIf++;
	for ( u8 i = 0; i< cb->numEndpoints; i++) {
		_initEndpoints[lastEp] = cb->endpointType[i];
		lastEp++;
	}
	modules_count++;
	return lastEp-1;
	// restart USB layer???
}

#endif

#endif /* if defined(USBCON) */