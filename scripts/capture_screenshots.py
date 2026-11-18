#!/usr/bin/env python3
"""Capture real App Store screenshots from the running app in the iOS Simulator.

The app is landscape only. simctl grabs the frame in the device's portrait
orientation, so each image is rotated to landscape and resized to the exact
size App Store Connect expects. Nothing is drawn onto the frame.

Usage: capture_screenshots.py <path-to-MinnaRec.app> [langs] [devices]
  langs   = comma list, default "ja,en"
  devices = comma list of iphone,ipad, default both
"""
import json, subprocess, sys, time, os
from PIL import Image

BUNDLE = "com.tokyonasu.MinnaRec"
APP = sys.argv[1]
LANGS = (sys.argv[2] if len(sys.argv) > 2 else "ja,en").split(",")
DEVICES = (sys.argv[3] if len(sys.argv) > 3 else "iphone,ipad").split(",")

IPHONE_PREFS = ["iPhone 16 Pro Max", "iPhone 17 Pro Max", "iPhone 15 Pro Max", "Pro Max"]
IPAD_PREFS = ["iPad Pro 13-inch", "iPad Pro (12.9-inch)", "iPad Air 13-inch", "iPad Pro", "iPad"]

IPHONE_SIZE = (2796, 1290)
IPAD_SIZE = (2732, 2048)

SCREENS = [str(i) for i in range(8)]  # see ScreenshotMode.plan
LOCALE = {"ja": "ja_JP", "en": "en_US"}


def sh(*a):
    return subprocess.run(a, check=True, capture_output=True, text=True)


def list_devices():
    data = json.loads(sh("xcrun", "simctl", "list", "devices", "available", "--json").stdout)["devices"]
    return [d for rt, lst in data.items() if "iOS" in rt for d in lst if d.get("isAvailable")]


def pick(devs, prefs):
    for p in prefs:
        for d in devs:
            if p in d["name"]:
                return d
    return None


def capture(udid, screen, lang, out):
    subprocess.run(["xcrun", "simctl", "terminate", udid, BUNDLE], capture_output=True)
    sh("xcrun", "simctl", "launch", udid, BUNDLE,
       "-AppleLanguages", f"({lang})", "-AppleLocale", LOCALE[lang],
       "-langJa", "YES" if lang == "ja" else "NO",
       "-screenshot", screen)
    time.sleep(7)
    sh("xcrun", "simctl", "io", udid, "screenshot", out)


def normalize(path, size):
    im = Image.open(path).convert("RGB")
    if im.width < im.height:
        im = im.rotate(90, expand=True)
    if im.size != size:
        im = im.resize(size, Image.LANCZOS)
    im.save(path)


def run_device(dev, kind, size):
    udid = dev["udid"]
    print("Using", dev["name"], udid, flush=True)
    subprocess.run(["xcrun", "simctl", "boot", udid], capture_output=True)
    sh("xcrun", "simctl", "bootstatus", udid, "-b")
    sh("xcrun", "simctl", "install", udid, APP)
    for lang in LANGS:
        folder = os.path.join("shots", lang, kind)
        os.makedirs(folder, exist_ok=True)
        for i, screen in enumerate(SCREENS, 1):
            out = os.path.join(folder, f"{i}.png")
            capture(udid, screen, lang, out)
            normalize(out, size)
            print("saved", out, flush=True)
    # 起動のようすを残す（白い画面や落ちたときの手がかり）
    log = subprocess.run(["xcrun", "simctl", "spawn", udid, "log", "show", "--last", "3m", "--style", "compact",
                          "--predicate", 'process == "MinnaRec"'], capture_output=True, text=True).stdout
    os.makedirs("shots", exist_ok=True)
    open(os.path.join("shots", f"log_{kind}.txt"), "w").write(log[-200000:])
    subprocess.run("cp ~/Library/Logs/DiagnosticReports/MinnaRec* shots/ 2>/dev/null", shell=True)
    subprocess.run(["xcrun", "simctl", "shutdown", udid], capture_output=True)


def main():
    devs = list_devices()
    targets = {"iphone": (IPHONE_PREFS, IPHONE_SIZE), "ipad": (IPAD_PREFS, IPAD_SIZE)}
    for kind in DEVICES:
        prefs, size = targets[kind]
        dev = pick(devs, prefs)
        if not dev:
            print("available devices:", [d["name"] for d in devs])
            raise SystemExit(f"No simulator for {kind}")
        run_device(dev, kind, size)
    print("Screenshots captured")


if __name__ == "__main__":
    main()
