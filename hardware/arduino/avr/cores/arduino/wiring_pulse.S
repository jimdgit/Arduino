/*
  wiring_pulse.s - pulseInASM() function in different flavours
  Part of Arduino - http://www.arduino.cc/

  Copyright (c) 2014 Martino Facchin

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
*/

#include <avr/io.h>

.section .text

.global countPulseASM

// bit is r25-24, state is r23-r22, timeout is r21-r18, *port is r17-r16
// these register do not need to be restored
// save r24 and r22 to r14,r15 for further use
// r25-r22 are used to store width and must be restored

countPulseASM:
push r14			; save r14-r15
push r15
mov r14, r24		; set r14 to r24 and r15 to r22
mov r15, r22		; r15 is now state
mov r25,r1			; zero r25-r22
mov r24,r1
mov r23,r1
mov r22,r1
loop:				; start loop
subi r22, 255		; increment width
sbci r23, 255
sbci r24, 255
sbci r25, 255
cp r22, r18			; compare width with timeout
cpc r23, r19
cpc r24, r20
cpc r25, r21
breq return_zero	; if equal, return 0
movw r30, r16		; save port state to unused r26
ld r26, Z
eor r26, r15		; xor with state
and r26, r14		; and with bit
cpi r26, 0
breq loop			; if equal, continue looping
rjmp exit
return_zero:
mov r22,r1          ; return 0 - timeout reached
mov r23,r1
mov r24,r1
mov r25,r1
exit:
pop r14
pop r15
ret
