/*
 * This file is part of Arduino.
 *
 * Arduino is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * As a special exception, you may use this file as part of a free software
 * library without restriction.  Specifically, if other files instantiate
 * templates or use macros or inline functions from this file, or you compile
 * this file and link it with other files to produce an executable, this
 * file does not by itself cause the resulting executable to be covered by
 * the GNU General Public License.  This exception does not however
 * invalidate any other reasons why the executable file might be covered by
 * the GNU General Public License.
 *
 * Copyright 2015 Arduino LLC (http://www.arduino.cc/)
 */

package cc.arduino.packages.discoverers.serial;

import cc.arduino.packages.BoardPort;
import cc.arduino.packages.discoverers.SerialDiscovery;
import processing.app.BaseNoGui;
import processing.app.Platform;
import processing.app.Serial;
import processing.app.debug.TargetBoard;

import java.util.*;

import org.usb4java.Context;
import org.usb4java.Device;
import org.usb4java.DeviceDescriptor;
import org.usb4java.HotplugCallback;
import org.usb4java.HotplugCallbackHandle;
import org.usb4java.LibUsb;
import org.usb4java.LibUsbException;

public class SerialBoardsLister extends Thread  {

  private final SerialDiscovery serialDiscovery;
  private EventHandlingThread thread = new EventHandlingThread();
  private HotplugCallbackHandle callbackHandle = new HotplugCallbackHandle();

  static class EventHandlingThread extends Thread
  {
    /** If thread should abort. */
    private volatile boolean abort;

    /**
     * Aborts the event handling thread.
     */
    public void abort()
    {
      this.abort = true;
    }

    @Override
    public void run()
    {
      while (!this.abort)
      {
        // Let libusb handle pending events. This blocks until events
        // have been handled, a hotplug callback has been deregistered
        // or the specified time (in Microseconds) has passed.
        int result = LibUsb.handleEventsTimeout(null, 10000);
        if (result != LibUsb.SUCCESS)
          throw new LibUsbException("Unable to handle events", result);
      }
    }
  }

  /**
   * The hotplug callback handler
   */
  class Callback implements HotplugCallback
  {
    @Override
    public int processEvent(Context context, Device device, int event,
                            Object userData)
    {
      DeviceDescriptor descriptor = new DeviceDescriptor();
      int result = LibUsb.getDeviceDescriptor(device, descriptor);
      if (result != LibUsb.SUCCESS)
        throw new LibUsbException("Unable to read device descriptor",
          result);
/*
        System.out.format("%s: %04x:%04x%n",
        event == LibUsb.HOTPLUG_EVENT_DEVICE_ARRIVED ? "Connected" :
          "Disconnected",
        descriptor.idVendor(), descriptor.idProduct());
        refreshSerialList();
*/
      return 0;
    }
  }

  public SerialBoardsLister(SerialDiscovery serialDiscovery) {
    this.serialDiscovery = serialDiscovery;
  }

  public void kill() {
    // Unregister the hotplug callback and stop the event handling thread
    thread.abort();
    LibUsb.hotplugDeregisterCallback(null, callbackHandle);
    try {
      thread.join();
    } catch (InterruptedException e) {}

    // Deinitialize the libusb context
    LibUsb.exit(null);
  }

  public void run() {
    refreshSerialList();
    // Initialize the libusb context
    int result = LibUsb.init(null);
    if (result != LibUsb.SUCCESS)
    {
      throw new LibUsbException("Unable to initialize libusb", result);
    }

    // Check if hotplug is available
    if (!LibUsb.hasCapability(LibUsb.CAP_HAS_HOTPLUG))
    {
      System.err.println("libusb doesn't support hotplug on this system");
      System.exit(1);
    }

    // Start the event handling thread
    thread.start();

    // Register the hotplug callback
    result = LibUsb.hotplugRegisterCallback(null,
      LibUsb.HOTPLUG_EVENT_DEVICE_ARRIVED
        | LibUsb.HOTPLUG_EVENT_DEVICE_LEFT,
      LibUsb.HOTPLUG_ENUMERATE,
      LibUsb.HOTPLUG_MATCH_ANY,
      LibUsb.HOTPLUG_MATCH_ANY,
      LibUsb.HOTPLUG_MATCH_ANY,
      new Callback(), null, callbackHandle);
    if (result != LibUsb.SUCCESS)
    {
      throw new LibUsbException("Unable to register hotplug callback",
        result);
    }
  }

  public void refreshSerialList() {
    while (BaseNoGui.packages == null) {
      try {
        Thread.sleep(1000);
      } catch (InterruptedException e) {
        // noop
      }
    }

    Platform platform = BaseNoGui.getPlatform();
    if (platform == null) {
      return;
    }

    List<BoardPort> boardPorts = new LinkedList<>();

    List<String> ports = Serial.list();

    String devicesListOutput = null;
    if (!ports.isEmpty()) {
      devicesListOutput = platform.preListAllCandidateDevices();
    }

    for (String port : ports) {
      Map<String, Object> boardData = platform.resolveDeviceByVendorIdProductId(port, BaseNoGui.packages, devicesListOutput);

      BoardPort boardPort = new BoardPort();
      boardPort.setAddress(port);
      boardPort.setProtocol("serial");

      String label = port;

      if (boardData != null) {
        boardPort.getPrefs().put("vid", boardData.get("vid").toString());
        boardPort.getPrefs().put("pid", boardData.get("pid").toString());
        boardPort.getPrefs().put("iserial", boardData.get("iserial").toString());

        TargetBoard board = (TargetBoard) boardData.get("board");
        if (board != null) {
          String boardName = board.getName();
          if (boardName != null) {
            label += " (" + boardName + ")";
          }
          boardPort.setBoardName(boardName);
        }
      }

      boardPort.setLabel(label);

      boardPorts.add(boardPort);
    }

    serialDiscovery.setSerialBoardPorts(boardPorts);
  }
}
