from gi.repository import Gio, GLib
from subprocess import run, Popen
from time import sleep
from multiprocessing import Process
import os
import signal

FILE="test.txt"
DELAY=20

def send_file(address, file):
    args = [
        "bluetooth-sendto",
        "--device",
        address,
        file
    ]
    return Popen(args)

proxy = Gio.DBusProxy.new_for_bus_sync(
        bus_type = Gio.BusType.SYSTEM,
        flags = Gio.DBusProxyFlags.NONE,
        info = None,
        name = "org.bluez",
        object_path = "/",
        interface_name = "org.freedesktop.DBus.ObjectManager",
        cancellable = None
        )


def read_objects() -> set[str]:
    """
    reads the objects connected to the
    network card
    """
    objs = proxy.GetManagedObjects()

    res = set()
    for data in objs.values():
        if "org.bluez.Device1" not in data:
            continue
        device = data["org.bluez.Device1"]
        address = device["Address"]
        name = device["Name"]
        res.add(address)
    return res

objects = read_objects()
print(f"Found {len(objects)} objects")
processes = list()
for addr in objects:
    print(f"serving {addr}")
    processes.append(send_file(addr, FILE))

sleep(DELAY)
for p in processes:
    p.kill()

for p in processes:
    p.wait()
