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
import javax.usb.*;
import javax.usb.event.*;
import org.usb4java.javax.Services;
import processing.app.helpers.OSUtils;

public class SerialBoardsLister extends Thread  implements UsbServicesListener {

  private final SerialDiscovery serialDiscovery;
  private List<String> previousPorts = new LinkedList<>();

  public SerialBoardsLister(SerialDiscovery serialDiscovery) {
    this.serialDiscovery = serialDiscovery;
  }

  @Override
  public void usbDeviceAttached(UsbServicesEvent event) {
    refreshSerialList();
  }

  @Override
  public void usbDeviceDetached(UsbServicesEvent event) {
    refreshSerialList();
  }

  @Override
  public void run() {
      refreshSerialList();
      try {
        final UsbServices services = UsbHostManager.getUsbServices();
        services.addUsbServicesListener(this);
      } catch (final UsbException e) {}
      // keep thread alive
      while (true) {
        try {
          if (OSUtils.isWindows()) {
            // libUSB hotplug unsupported on Windows
            refreshSerialList();
          }
          Thread.sleep(1000);
        } catch (InterruptedException e) {
          // noop
        }
      }
    }

  public void refreshSerialList()  {
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

    if (OSUtils.isWindows()) {
      if (previousPorts.equals(ports)) {
        return;
      } else {
        previousPorts.clear();
        previousPorts.addAll(ports);
      }
    }

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
