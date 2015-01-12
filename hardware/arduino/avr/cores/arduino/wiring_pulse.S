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

#if 0	// commented version, unusable for macro expansion

// bit is r25-24, state is r23-r22, timeout is r21-r18
// these register do not need to be restored
// save r24 and r22 to r16,r17 for further use
// r25-r22 are used to store width and must be restored

#define countPulseASM_gen(X)  								 \
countPulseASM_##X:										$	 \
push r17			; 	save r17-r15					$	 \
push r16												$	 \
push r15												$	 \
mov r16, r24		; set r16 to r24 and r17 to r22     $    \
mov r17, r22		; r17 is now state                  $    \
mov r25,r1       	; zero r25-r22                      $    \
mov r24,r1												$	 \
mov r23,r1                                              $    \
mov r22,r1                                              $    \
loop_##X:            ; start loop                       $    \
subi r22, 255        ; increment width                  $    \
sbci r23, 255                                           $    \
sbci r24, 255                                           $    \
sbci r25, 255                                           $    \
cp r22, r18          ; compare width with timeout       $    \
cpc r23, r19                                            $    \
cpc r24, r20                                            $    \
cpc r25, r21                                            $    \
breq return_zero_##X  ; if equal, return 0              $    \
in r26, PIN##X - 0x20 ; save port state to unused r26   $    \
eor r26, r17     	  ; xor with state                  $    \
and r26, r16          ; and with bit                    $    \
cpi r26, 0            ; compare with zero               $    \
breq loop_##X         ; if equal, continue looping      $    \
rjmp exit_##X                                           $    \
return_zero_##X:                                        $    \
mov r22,r1            ; return 0 - timeout reached      $    \
mov r23,r1                                              $    \
mov r24,r1                                              $    \
mov r25,r1												$	 \
exit_##X:                                               $    \
pop r17													$    \
pop r16													$    \
pop r15													$    \
ret

#endif

#define countPulseASM_gen(X)	.global countPulseASM_##X	$\
countPulseASM_##X:	$\
push r17				$\
push r16				$\
push r15				$\
mov r16, r24			$\
mov r17, r22			$\
mov r25, r1				$\
mov r24, r1				$\
mov r23, r1				$\
mov r22, r1				$\
loop_##X:				$\
subi r22, 255			$\
sbci r23, 255			$\
sbci r24, 255			$\
sbci r25, 255			$\
cp r22, r18				$\
cpc r23, r19			$\
cpc r24, r20			$\
cpc r25, r21			$\
breq return_zero_##X	$\
in r26, PIN##X - 0x20	$\
eor r26, r17			$\
and r26, r16			$\
cpi r26, 0				$\
breq loop_##X			$\
rjmp exit_##X			$\
return_zero_##X:		$\
mov r22, r1				$\
mov r23, r1				$\
mov r24, r1				$\
mov r25, r1				$\
exit_##X:				$\
pop r17					$\
pop r16					$\
pop r15					$\
ret

.section .text

countPulseASM_gen(B)
countPulseASM_gen(C)
countPulseASM_gen(D)


#if defined(__AVR_ATmega1280__)||defined(__AVR_ATmega2560__)

countPulseASM_gen(E)
countPulseASM_gen(F)
countPulseASM_gen(G)

#endif
