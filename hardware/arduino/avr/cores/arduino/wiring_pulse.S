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

countPulseASM_B:
push	r17
mov r24,r1
mov r25,r1
loop_b:
adiw r24, 1
cp r24, r20
cpc r25, r21
breq return_zero_b
//check the pin state to be consistent with the mask
in r17, PINB-0x20
eor r17, r18
and r17, r22
cpi r17, 0
breq loop_b
//sbic PINB-0x20, 7
//rjmp loop
ret_belay_b:
rjmp exit_b
return_zero_b:
mov r24,r1
mov r25,r1
exit_b:
pop	r17
ret


countPulseASM_C:
push	r17
mov r24,r1
mov r25,r1
loop_c:
adiw r24, 1
cp r24, r20
cpc r25, r21
breq return_zero_c
//check the pin state to be consistent with the mask
in r17, PINC-0x20
eor r17, r18
and r17, r22
cpi r17, 0
breq loop_c
//sbic PINC-0x20, 7
//rjmp loop
ret_celay_c:
rjmp exit_c
return_zero_c:
mov r24,r1
mov r25,r1
exit_c:
pop	r17
ret


countPulseASM_D:
push	r17
mov r24,r1
mov r25,r1
loop_d:
adiw r24, 1
cp r24, r20
cpc r25, r21
breq return_zero_d
//check the pin state to be consistent with the mask
in r17, PIND-0x20
eor r17, r18
and r17, r22
cpi r17, 0
breq loop_d
//sbic PIND-0x20, 7
//rjmp loop
ret_delay_d:
rjmp exit_d
return_zero_d:
mov r24,r1
mov r25,r1
exit_d:
pop	r17
ret
