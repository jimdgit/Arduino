/*
  wiring_pulse.c - pulseIn() function
  Part of Arduino - http://www.arduino.cc/

  Copyright (c) 2005-2006 David A. Mellis

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA

  $Id: wiring.c 248 2007-02-03 15:36:30Z mellis $
*/

#include <avr/io.h>

.global countPulseASM

.section .text

countPulseASM:
push	r16      
push	r17      
push	r28      
push	r29
//clear r16:r17
mov r16, r24
mov r17, r25
mov r24,r1
mov r25,r1
loop:
adiw r24, 1
cp r24, r20
cpc r25, r21
breq return_zero
sbic PIND-0x20, 7
//sbic r16, r22
rjmp loop
ret_delay:
rjmp exit
return_zero:
mov r24,r1
mov r25,r1
exit:
pop	r29 
pop	r28 
pop	r17 
pop	r16 
ret     

