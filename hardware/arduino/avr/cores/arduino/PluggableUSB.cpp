

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

//PUSBCallbacks cbs[MAX_MODULES];
static u8 modules_count = 0;

static PUSBListNode* rootNode = NULL;
static PUSBListNode* lastNode = NULL;

int8_t PUSB_GetInterface(u8* interfaceNum)
{
	int8_t ret = 0;
	PUSBListNode* node = rootNode;
	for (u8 i=0; i<modules_count; i++) {
		ret = node->cb->getInterface(interfaceNum);
		node = node->next;
	}
	return ret;
}

int8_t PUSB_GetDescriptor(int8_t t)
{
	int8_t ret = 0;
	PUSBListNode* node = rootNode;
	for (u8 i=0; i<modules_count && ret == 0; i++) {
		ret = node->cb->getDescriptor(t);
		node = node->next;
	}
	return ret;
}

bool PUSB_Setup(Setup& setup, u8 j)
{
	bool ret = false;
	PUSBListNode* node = rootNode;
	for (u8 i=0; i<modules_count && ret == false; i++) {
		ret = node->cb->setup(setup, j);
		node = node->next;
	}
	return ret;
}

int8_t PUSB_AddFunction(PUSBListNode *node, u8* interface)
{
	if (modules_count >= MAX_MODULES) {
		return 0;
	}

	if (modules_count == 0) {
		rootNode = node;
		lastNode = node;
	} else {
		lastNode->next = node;
	}

	*interface = lastIf;
	lastIf += node->cb->numInterfaces;
	for ( u8 i = 0; i< node->cb->numEndpoints; i++) {
		_initEndpoints[lastEp] = node->cb->endpointType[i];
		lastEp++;
	}
	modules_count++;
	return lastEp - node->cb->numEndpoints;
	// restart USB layer???
}

#endif

#endif /* if defined(USBCON) */