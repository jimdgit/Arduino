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

#include "wiring_private.h"
#include "pins_arduino.h"

uint16_t (*countPulseASM)(const uint8_t port, const uint8_t bit, uint16_t maxloops, uint8_t state);

uint16_t __attribute__((optimize("O0"))) count_pulse(uint8_t port, uint8_t bit, uint8_t stateMask, uint16_t maxloops)
{
	uint16_t tmp = 0;
	while ((*portInputRegister(port) & bit) == stateMask) {
		if (tmp++ == maxloops) {
			return 0;
		}
	}
	return (tmp);
}

/* Measures the length (in microseconds) of a pulse on the pin; state is HIGH
 * or LOW, the type of pulse to measure.  Works on pulses from 2-3 microseconds
 * to 3 minutes in length, but must be called at least a few dozen microseconds
 * before the start of the pulse. */
unsigned long pulseIn(uint8_t pin, uint8_t state, unsigned long timeout)
{
	// cache the port and bit of the pin in order to speed up the
	// pulse width measuring loop and achieve finer resolution.  calling
	// digitalRead() instead yields much coarser resolution.
	uint8_t bit = digitalPinToBitMask(pin);
	uint8_t port = digitalPinToPort(pin);
	uint8_t stateMask = (state ? bit : 0);
	unsigned long width = 0; // keep initialization out of time critical area

	switch (port) {
		case 2:
			//portB
			countPulseASM = &countPulseASM_B;
			break;
		case 3:
			//portC
			countPulseASM = &countPulseASM_C;
			break;
		case 4:
			//portD
			countPulseASM = &countPulseASM_D;
			break;
		default:
			return 0;
	}

	// convert the timeout from microseconds to a number of times through
	// the initial loop; it takes 16 clock cycles per iteration.
	unsigned long numloops = 0;
	unsigned long maxloops = microsecondsToClockCycles(timeout);
	
	// wait for any previous pulse to end
	while ((*portInputRegister(port) & bit) == stateMask)
		if (numloops++ == maxloops)
			return 0;
	
	// wait for the pulse to start
	while ((*portInputRegister(port) & bit) != stateMask)
		if (numloops++ == maxloops)
			return 0;

#if 1
	width = countPulseASM(*portInputRegister(port), bit, maxloops, stateMask);
	return clockCyclesToMicroseconds(width * 11);
#else
    unsigned long start = micros();
    // wait for the pulse to stop
    while ((*portInputRegister(port) & bit) == stateMask) {
        if (numloops++ == maxloops)
            return 0;
    }
    return micros() - start;
#endif
}
