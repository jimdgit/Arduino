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

.global countPulseASM_B
.global countPulseASM_C
.global countPulseASM_D

.section .text

// bit is r25-24, state is r23-r22, timeout is r21-r18
// these register do not need to be restored
// save r24 and r22 to r16,r17 for further use
// r25-r22 are used to store width and must be restored

countPulseASM_B:
// save r17-r15
push r17
push r16
push r15
// set r16 to r24 and r17 to r22
mov r16, r24		; r16 is now bit
mov r17, r22		; r17 is now state
// zero r25-r22
mov r25,r1
mov r24,r1
mov r23,r1
mov r22,r1
// start loop
loop_B:
// increment width
subi r22, 255
sbci r23, 255
sbci r24, 255
sbci r25, 255
// compare width with timeout
cp r22, r18
cpc r23, r19
cpc r24, r20
cpc r25, r21
// if equal, return 0
breq return_zero_B
// check the pin state to be consistent with the mask
// save port state to unused r26
in r26, PINB-0x20
// xor with state
eor r26, r17
// and with bit
and r26, r16
// compare with zero
cpi r26, 0
// if equal, continue looping
breq loop_B
// jump to exit_B
rjmp exit_B
return_zero_B:
// return 0 - timeout reached
mov r22,r1
mov r23,r1
mov r24,r1
mov r25,r1
exit_B:
//restore registers
pop r17
pop r16
pop r15
ret


countPulseASM_C:
// save r17-r15
push r17
push r16
push r15
// set r16 to r24 and r17 to r22
mov r16, r24		; r16 is now bit
mov r17, r22		; r17 is now state
// zero r25-r22
mov r25,r1
mov r24,r1
mov r23,r1
mov r22,r1
// start loop
loop_C:
// increment width
subi r22, 255
sbci r23, 255
sbci r24, 255
sbci r25, 255
// compare width with timeout
cp r22, r18
cpc r23, r19
cpc r24, r20
cpc r25, r21
// if equal, return 0
breq return_zero_C
// check the pin state to be consistent with the mask
// save port state to unused r26
in r26, PINC-0x20
// xor with state
eor r26, r17
// and with bit
and r26, r16
// compare with zero
cpi r26, 0
// if equal, continue looping
breq loop_C
// jump to exit_C
rjmp exit_C
return_zero_C:
// return 0 - timeout reached
mov r22,r1
mov r23,r1
mov r24,r1
mov r25,r1
exit_C:
//restore registers
pop r17
pop r16
pop r15
ret


countPulseASM_D:
// save r17-r15
push r17
push r16
push r15
// set r16 to r24 and r17 to r22
mov r16, r24		; r16 is now bit
mov r17, r22		; r17 is now state
// zero r25-r22
mov r25,r1
mov r24,r1
mov r23,r1
mov r22,r1
// start loop
loop_D:
// increment width
subi r22, 255
sbci r23, 255
sbci r24, 255
sbci r25, 255
// compare width with timeout
cp r22, r18
cpc r23, r19
cpc r24, r20
cpc r25, r21
// if equal, return 0
breq return_zero_D
// check the pin state to be consistent with the mask
// save port state to unused r26
in r26, PIND-0x20
// xor with state
eor r26, r17
// and with bit
and r26, r16
// compare with zero
cpi r26, 0
// if equal, continue looping
breq loop_D
// jump to exit_D
rjmp exit_D
return_zero_D:
// return 0 - timeout reached
mov r22,r1
mov r23,r1
mov r24,r1
mov r25,r1
exit_D:
//restore registers
pop r17
pop r16
pop r15
ret


#if defined(__AVR_ATmega1280__)||defined(__AVR_ATmega2560__)

.global countPulseASM_E
.global countPulseASM_F
.global countPulseASM_G

countPulseASM_E:
// save r17-r15
push r17
push r16
push r15
// set r16 to r24 and r17 to r22
mov r16, r24		; r16 is now bit
mov r17, r22		; r17 is now state
// zero r25-r22
mov r25,r1
mov r24,r1
mov r23,r1
mov r22,r1
// start loop
loop_E:
// increment width
subi r22, 255
sbci r23, 255
sbci r24, 255
sbci r25, 255
// compare width with timeout
cp r22, r18
cpc r23, r19
cpc r24, r20
cpc r25, r21
// if equal, return 0
breq return_zero_E
// check the pin state to be consistent with the mask
// save port state to unused r26
in r26, PINE-0x20
// xor with state
eor r26, r17
// and with bit
and r26, r16
// compare with zero
cpi r26, 0
// if equal, continue looping
breq loop_E
// jump to exit_E
rjmp exit_E
return_zero_E:
// return 0 - timeout reached
mov r22,r1
mov r23,r1
mov r24,r1
mov r25,r1
exit_E:
//restore registers
pop r17
pop r16
pop r15
ret


countPulseASM_F:
// save r17-r15
push r17
push r16
push r15
// set r16 to r24 and r17 to r22
mov r16, r24		; r16 is now bit
mov r17, r22		; r17 is now state
// zero r25-r22
mov r25,r1
mov r24,r1
mov r23,r1
mov r22,r1
// start loop
loop_F:
// increment width
subi r22, 255
sbci r23, 255
sbci r24, 255
sbci r25, 255
// compare width with timeout
cp r22, r18
cpc r23, r19
cpc r24, r20
cpc r25, r21
// if equal, return 0
breq return_zero_F
// check the pin state to be consistent with the mask
// save port state to unused r26
in r26, PINF-0x20
// xor with state
eor r26, r17
// and with bit
and r26, r16
// compare with zero
cpi r26, 0
// if equal, continue looping
breq loop_F
// jump to exit_F
rjmp exit_F
return_zero_F:
// return 0 - timeout reached
mov r22,r1
mov r23,r1
mov r24,r1
mov r25,r1
exit_F:
//restore registers
pop r17
pop r16
pop r15
ret


countPulseASM_G:
// save r17-r15
push r17
push r16
push r15
// set r16 to r24 and r17 to r22
mov r16, r24		; r16 is now bit
mov r17, r22		; r17 is now state
// zero r25-r22
mov r25,r1
mov r24,r1
mov r23,r1
mov r22,r1
// start loop
loop_G:
// increment width
subi r22, 255
sbci r23, 255
sbci r24, 255
sbci r25, 255
// compare width with timeout
cp r22, r18
cpc r23, r19
cpc r24, r20
cpc r25, r21
// if equal, return 0
breq return_zero_G
// check the pin state to be consistent with the mask
// save port state to unused r26
in r26, PING-0x20
// xor with state
eor r26, r17
// and with bit
and r26, r16
// compare with zero
cpi r26, 0
// if equal, continue looping
breq loop_G
// jump to exit_G
rjmp exit_G
return_zero_G:
// return 0 - timeout reached
mov r22,r1
mov r23,r1
mov r24,r1
mov r25,r1
exit_G:
//restore registers
pop r17
pop r16
pop r15
ret

#endif
