#ifndef MOUSE_h
#define MOUSE_h

#if 0 //defined(_USING_HID)

#error "Can only attach one submodule to HID module"

#else

#define _USING_HID

#include "HID.h"
//================================================================================
//================================================================================
//  Mouse

#define MOUSE_LEFT 1
#define MOUSE_RIGHT 2
#define MOUSE_MIDDLE 4
#define MOUSE_ALL (MOUSE_LEFT | MOUSE_RIGHT | MOUSE_MIDDLE)

class Mouse_
{
private:
  uint8_t _buttons;
  void buttons(uint8_t b);
public:
  Mouse_(void);
  void begin(void);
  void end(void);
  void click(uint8_t b = MOUSE_LEFT);
  void move(signed char x, signed char y, signed char wheel = 0); 
  void press(uint8_t b = MOUSE_LEFT);   // press LEFT by default
  void release(uint8_t b = MOUSE_LEFT); // release LEFT by default
  bool isPressed(uint8_t b = MOUSE_LEFT); // check LEFT by default
};
extern Mouse_ Mouse;
extern HID_ HID;

#endif
#endif