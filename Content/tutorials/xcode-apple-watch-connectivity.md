# Xcode & Apple Watch: Symbol Copying, Device Connectivity & Debugging
> A detailed technical reference compiled from a real debugging session — March 2026  
> Environment: macOS 26.3.1, Xcode 26.3, watchOS 26.3 / watchOS 10.6.2

---

## Table of Contents

1. [What is "Copying Shared Cache Symbols"?](#1-what-is-copying-shared-cache-symbols)
2. [Observing Copy Progress from the Terminal](#2-observing-copy-progress-from-the-terminal)
3. [Understanding the Full Size](#3-understanding-the-full-size)
4. [Does Size Vary Per Watch?](#4-does-size-vary-per-watch)
5. [Real-World Size & Timing Data](#5-real-world-size--timing-data)
6. [Copying Symbols for Multiple Devices](#6-copying-symbols-for-multiple-devices)
7. [Triggering Symbol Copy from the CLI](#7-triggering-symbol-copy-from-the-cli)
8. [Multiple Apple Watches](#8-multiple-apple-watches)
9. [Xcode Downloads Error: HTTP 403 Forbidden](#9-xcode-downloads-error-http-403-forbidden)
10. [CoreDevice Tunnel Timeout (NWError 60)](#10-coredevice-tunnel-timeout-nwerror-60)
11. [Keeping the Watch Awake During Copy](#11-keeping-the-watch-awake-during-copy)
12. [Apple Watch Series 5 Not Detected in Xcode 26](#12-apple-watch-series-5-not-detected-in-xcode-26)
13. [Debugging with devicectl](#13-debugging-with-devicectl)
14. [Series 5 arm64_32 Tunnel Failure](#14-series-5-arm64_32-tunnel-failure)
15. [Resolution: WiFi vs Hotspot](#15-resolution-wifi-vs-hotspot)
16. [Quick Reference: Key Commands](#16-quick-reference-key-commands)
17. [Known Issues & Workarounds Summary](#17-known-issues--workarounds-summary)

---

## 1. What is "Copying Shared Cache Symbols"?

When Xcode shows **"Copying shared cache symbols from [Device] (0% completed)"**, it is pulling the **dyld shared cache** from your Apple Watch (or iPhone) to your Mac.

### What is the dyld shared cache?

Apple devices combine all system frameworks (UIKit, Foundation, SwiftUI, etc.) into a single optimized binary called the **dyld shared cache**. This makes app launches faster on-device, but the debug symbols for those frameworks live on the device — not your Mac.

Xcode needs to copy those symbols locally so it can:
- **Symbolicate crash logs** — turning memory addresses into readable function names
- **Show system framework code** in the debugger
- **Display proper backtraces** when paused at a breakpoint

### Where symbols are stored on your Mac

```
~/Library/Developer/Xcode/iOS DeviceSupport/
~/Library/Developer/Xcode/watchOS DeviceSupport/
```

Each subfolder follows the naming convention:
```
Watch5,2 7.0 (18R382)
Watch7,5 26.3 (23S620)
```

These folders can grow to **2–5 GB per OS version** and accumulate over time.

### When does it trigger?

- First time connecting a new device
- After a watchOS/iOS update
- If you delete the DeviceSupport folder manually
- Occasionally after Xcode updates

> **Note:** The copy runs in the background and does not block building or running your app — it only affects symbolication until complete.

---

## 2. Observing Copy Progress from the Terminal

### Watch the folder grow (macOS built-in, no `watch` command)

macOS doesn't ship with the `watch` command. Use a shell loop instead:

```bash
while true; do
  echo "$(date +%H:%M:%S) $(du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/)"
  sleep 2
done
```

Or install `watch` via Homebrew:

```bash
brew install watch
watch -n 2 'du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/'
```

### Track the dyld subfolder specifically

```bash
du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*/dyld/
```

### Stream CoreDevice logs

```bash
log stream --predicate 'subsystem contains "com.apple.coredevice"' --style compact
```

### Check open file handles

```bash
lsof -c Xcode | grep -i dyld
```

This shows which symbol file Xcode is actively writing.

### Prevent Mac from sleeping during copy

```bash
caffeinate -i &
```

---

## 3. Understanding the Full Size

There is no clean public API that exposes "X of Y bytes copied" outside of Xcode's UI. Xcode's progress comes from internal `DVTFoundation` / `CoreDevice` framework callbacks that aren't scripting-friendly.

### Attempting to check source size via devicectl

`xcrun devicectl device info files` is sandboxed to app containers only (domain types: `appDataContainer`, `temporary`, `appGroupDataContainer`, `systemCrashLogs`). It **cannot** read arbitrary system paths like `/System/Library/Caches/com.apple.dyld/`.

### Best workarounds

**Check completed prior versions for a size reference:**

```bash
du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*/
```

**Calculate a rough percentage manually:**

1. Note the final size after a successful copy completes once
2. Use that as your denominator for future copies
3. Divide current folder size by expected total

---

## 4. Does Size Vary Per Watch?

Yes, it varies based on:

| Factor | Impact |
|--------|--------|
| **watchOS version** | Biggest factor — grows with each OS release |
| **Watch hardware generation** | Different chips can have slightly different caches |
| **Architecture** | All modern Watches are arm64 (Series 6+); Series 4/5 use arm64_32 |

Watches running the **same watchOS version on the same chip family** will have essentially identical shared caches.

---

## 5. Real-World Size & Timing Data

> Source: Apple Developer Forums, MacRumors, 9to5Mac, developer blogs — March 2026

### Folder sizes

- **Per watchOS version:** approximately **2–5 GB**
- **watchOS vs iOS comparison:** one direct measurement showed watchOS DeviceSupport at **4.3 GB** while iOS DeviceSupport was **9.7 GB** on the same machine — suggesting watchOS symbols are roughly half the size of iOS
- **watchOS 10/11 on S9 hardware (estimated):** **1.5–3 GB** per version (inferred, not directly measured)

> No developer has publicly posted a precise GB measurement for watchOS 10 or 11 on S9/Ultra hardware as of March 2026.

### Copy times from physical Apple Watch

| Scenario | Time |
|----------|------|
| Successful copy | ~1 hour |
| Sitting at 0% before progressing | 20–30+ minutes |
| Failed/timed out | Indefinite |

Apple Watch symbols transfer **wirelessly** through Bluetooth→WiFi, routed via the paired iPhone. This makes the process dramatically slower and more failure-prone than iPhone USB symbol copying.

### Xcode 12+ automatic cleanup

DeviceSupport files unused for **180 days** are marked eligible for system deletion.

---

## 6. Copying Symbols for Multiple Devices

Xcode has no bulk "sync all devices" mode — copies happen **one at a time per wireless device**.

### Strategy

| Device type | Connection | Approach |
|-------------|------------|----------|
| iPhone / iPad | USB | Plug multiple in simultaneously via hub — Xcode queues them |
| Apple Watch | Wireless | Serial only — do one at a time |

### Checking what you already have

```bash
ls ~/Library/Developer/Xcode/watchOS\ DeviceSupport/
ls ~/Library/Developer/Xcode/iOS\ DeviceSupport/
```

If a version folder already exists, Xcode won't re-copy it.

### Forcing a copy if Xcode doesn't start automatically

In **Devices and Simulators**, select the device and look for a "Prepare for Development" prompt, or just run a build targeting that device.

---

## 7. Triggering Symbol Copy from the CLI

There is **no clean public CLI** for triggering the dyld symbol copy directly. Apple hasn't exposed a dedicated command.

### Closest approach: xcodebuild targeting the device

```bash
xcodebuild -scheme YourScheme \
  -destination 'id=<UDID>' \
  build
```

When `xcodebuild` targets a physical device it doesn't have symbols for, it triggers the same copy process as Xcode's UI.

### List connected devices and UDIDs

```bash
xcrun devicectl list devices
```

### The dsc_extractor (local extraction only)

Apple provides `dsc_extractor` internally — used by Xcode when connecting a device for debugging. It can split libraries from a cache file, but requires the cache to already be on your Mac. It does not pull from the device.

Location:
```
/Applications/Xcode.app/Contents/Developer/Platforms/
  iPhoneOS.platform/usr/lib/dsc_extractor.bundle
```

---

## 8. Multiple Apple Watches

### Architecture

Apple Watch connects to your Mac **through its paired iPhone**:

```
Mac ← USB/WiFi → iPhone ← Bluetooth/WiFi → Apple Watch
```

This means:
- Each Watch must be paired to an iPhone
- That iPhone must be connected to your Mac
- The Watch cannot connect directly to your Mac

### Multiple Watches paired to the same iPhone

Xcode should serialize them — finishing one before starting the next. Target each by UDID:

```bash
for UDID in <watch1_udid> <watch2_udid>; do
  xcodebuild -scheme YourWatchScheme \
    -destination "id=$UDID" \
    build
done
```

### Multiple Watches paired to different iPhones

Each Watch-iPhone pair needs its own iPhone connected to your Mac. Parallelization is not well-documented or reliable.

---

## 9. Xcode Downloads Error: HTTP 403 Forbidden

**Error shown in Xcode Downloads panel:**
```
Symbols for watchOS 26.3 (23S620)
Failed — Failed with HTTP status 403: forbidden
```

### What this means

Xcode attempted to download symbols from Apple's CDN instead of copying from the physical device, and received a 403 Forbidden response.

watchOS 26.3 (build 23S620) is a fully public release (shipped February 11, 2026) — so this is not a "symbols not yet published" issue.

### Likely causes

| Cause | Fix |
|-------|-----|
| Stale Apple ID session | Xcode → Settings → Accounts → Sign out and back in |
| Xcode version predates the OS release | Update Xcode |
| VPN or network filtering blocking Apple's CDN | Disable VPN, check proxy settings |
| Partial/failed download entry cached | Delete and retry |

### Force Xcode to copy from device instead

Delete the failed DeviceSupport folder so Xcode falls back to device copy:

```bash
rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport/"Watch* 26.3*"
```

Then disconnect and reconnect the Watch in Devices and Simulators.

---

## 10. CoreDevice Tunnel Timeout (NWError 60)

**Full error:**
```
The tunnel was interrupted while establishing connectivity to coredevice-18.
Domain: com.apple.dt.CoreDeviceError
Code: 4000
Failure Reason: The operation couldn't be completed. (Network.NWError error 60 - Operation timed out)
```

### What this means

Modern Xcode uses a **CoreDevice tunnel** (a VPN-like connection over WiFi) to communicate with Apple Watch. `NWError 60` (POSIX `ETIMEDOUT`) means the tunnel handshake started but the Watch didn't respond in time.

### Common causes

- Watch and Mac not on the same WiFi network
- Watch connected to 5 GHz — Watch only supports **2.4 GHz**
- Router band steering mixing 2.4/5 GHz automatically
- VPN active on Mac conflicting with CoreDevice tunnel
- Watch screen turning off during tunnel negotiation (~70 second default timeout)
- iPhone going to sleep or losing Bluetooth connection to Watch

### Fixes

**WiFi:**
- Ensure Mac, iPhone, and Watch are all on the same **2.4 GHz** network
- If router uses band steering, force Mac to 2.4 GHz temporarily
- Disable VPN on Mac

**Keep Watch awake:**
- Settings → Display & Brightness → set wake duration to maximum (70 seconds)
- Enable Always On Display (Apple Watch Ultra/Series 5+)
- Put Watch on charger — it stays more active and keeps WiFi connected

**Reset CoreDevice tunnel state:**
```bash
sudo killall -9 remoted
sudo killall -9 companionappd
```
Then unplug and replug the iPhone.

**Prevent Mac from sleeping:**
```bash
caffeinate -i &
```

---

## 11. Keeping the Watch Awake During Copy

Placing the Watch **on its charger** during symbol copy is recommended:

- Watch stays in a more active power state
- WiFi remains connected rather than cycling to save battery
- CoreDevice tunnel has better chance of completing before timeout

### Ideal setup

1. Put Watch on charger, nearby your Mac
2. Connect iPhone to Mac via USB
3. Open Xcode → Window → Devices and Simulators
4. Run `caffeinate -i &` to prevent Mac sleep
5. Let the copy run — do not let Mac or Watch sleep

---

## 12. Apple Watch Series 5 Not Detected in Xcode 26

### Environment
- Mac: macOS 26.3.1, Xcode 26.3
- Watch: Apple Watch Series 5, watchOS 10.6.2 (`arm64_32` architecture)
- Paired iPhone: iPhone 15 Pro Max, iOS 26.x (connected via USB)

### Xcode 26 device support range

Xcode 26 supports watchOS 8 or later — so watchOS 10.6.2 is within range. This is not a compatibility issue.

### Symptoms

- Watch does not appear in Xcode → Window → Devices and Simulators
- Watch does not appear in `xcrun devicectl list devices`
- iPhone shows up fine
- No paired Watch section visible under the iPhone in Devices

### Checklist that was verified

| Check | Status |
|-------|--------|
| Series 5 paired to connected iPhone | ✅ |
| iPhone shows in Xcode | ✅ |
| iPhone on iOS 26 | ✅ |
| Developer Mode on Watch | ✅ Enabled |
| devicectl sees Watch | ❌ Initially absent |

### Resolution: Trust dialog

After toggling WiFi and Bluetooth, a **"Trust MacBook Air"** dialog appeared on the Watch. Accepting it caused the Watch to appear in `devicectl list devices` as `available (paired)`.

**Key lesson:** The trust dialog must be completed on the Watch before CoreDevice can enumerate it, even if Developer Mode is already enabled.

---

## 13. Debugging with devicectl

### List all devices

```bash
xcrun devicectl list devices
```

**Output fields:**

| Field | Meaning |
|-------|---------|
| `connected` | Directly connected (USB), fully usable |
| `available (paired)` | Reachable over network tunnel |
| `unavailable` | Known to CoreDevice but tunnel not established |

### Get detailed device info

```bash
xcrun devicectl device info details --device <UUID>
```

**Key fields to inspect:**

```
tunnelState: disconnected    ← tunnel not established
ddiServicesAvailable: false  ← Developer Disk Image not mounted
transportType: localNetwork  ← using WiFi, not USB
cpuType: arm64_32            ← Series 4/5 only
pairingState: paired         ← trust completed
```

### Reboot a device

```bash
xcrun devicectl device reboot -d <UUID>
```

> **Note:** Different subcommands use different flags: `info details` uses `--device`, while `reboot` uses `-d`. This inconsistency is a known annoyance in Xcode 26's `devicectl`.

### Common devicectl error (safely ignored)

```
Failed to load provisioning parameter list due to error:
Error Domain=com.apple.dt.CoreDeviceError Code=1002 "No provider was found."
```

This appears on every `devicectl` invocation when no provisioning profile context is active. It is a known Xcode 26 bug and can be ignored — it does not affect device connectivity.

---

## 14. Series 5 arm64_32 Tunnel Failure

### The problem

The Apple Watch Series 5 uses `arm64_32` — a 32-bit address space on an ARM64 chip. All watches from Series 6 onwards use full `arm64`.

Despite the Series 5 appearing as `available (paired)` in `devicectl`, every command requiring a live tunnel fails with:

```
ERROR: A connection to this device could not be established.
       (com.apple.dt.CoreDeviceError error 4000)
ERROR: The operation couldn't be completed. Operation timed out
       (NSPOSIXErrorDomain error 60)
```

### Evidence

From `devicectl device info details`:

```
cpuType: arm64_32 (type: 33554444, subtype: 1)
tunnelState: disconnected
ddiServicesAvailable: false
transportType: localNetwork
tunnelTransportProtocol: tcp
```

Every command that requires a live connection fails — including `reboot`, `process launch`, `sysdiagnose`.

### Root cause hypothesis

Xcode 26's CoreDevice tunnel protocol implementation may have broken or dropped support for `arm64_32` Watch tunnel establishment. The Series 5 is the only Apple Watch CPU type that is simultaneously:
- Still within Xcode 26's device support range (watchOS 8+)
- Using the older `arm64_32` architecture
- Paired to a phone running iOS 26

### Workarounds

1. **Hotspot bootstrap (confirmed working)** — enable Personal Hotspot on the paired iPhone, connect Mac to it, wait for Watch to appear as `available (paired)`, then switch Mac back to regular WiFi. Symbol copy continues on regular WiFi.

2. **Keep Xcode 16 installed** alongside Xcode 26 for Series 5 testing as a fallback:
   ```bash
   sudo xcode-select -s /Applications/Xcode16.app/Contents/Developer
   ```

3. **Use a watchOS 10 simulator** in Xcode 26 for most test coverage

4. **File a Feedback report** via Feedback Assistant with the `devicectl` output

---

## 15. Resolution: Hotspot to Bootstrap, Then Switch Back to WiFi

### The working pattern (confirmed for all watches)

The Personal Hotspot acts as a **bootstrap** to get the initial CoreDevice tunnel established. Once the tunnel is up, you can switch back to regular WiFi and the symbol copy continues uninterrupted.

**Step-by-step:**

1. Enable **Personal Hotspot** on the paired iPhone
2. Connect your Mac to that hotspot
3. Wait for the Watch to appear as `available (paired)` in `devicectl list devices`
4. Switch your Mac back to regular **WiFi**
5. Symbol copy proceeds normally on regular WiFi

> This pattern was confirmed to work for the Apple Watch Series 5 (watchOS 10.6.2, arm64_32). The hotspot is only needed to bootstrap the connection — not for the duration of the copy.

### Why this works

The Personal Hotspot creates a more direct Mac→iPhone→Watch network path, which is reliable enough to complete the CoreDevice tunnel handshake that times out over a typical home/office router. Once the tunnel is established, the lower-latency regular WiFi path takes over cleanly.

### Confirming copy progress after switching back to WiFi

```bash
du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*/
```

If the folder size is growing, the copy is proceeding. You can also confirm the Watch is still reachable:

```bash
xcrun devicectl device reboot -d <UUID>
```

---

## 16. Quick Reference: Key Commands

```bash
# List all CoreDevice-visible devices
xcrun devicectl list devices

# Get detailed info for a specific device
xcrun devicectl device info details --device <UUID>

# Reboot a device
xcrun devicectl device reboot -d <UUID>

# Stream CoreDevice logs
log stream --predicate 'subsystem contains "com.apple.coredevice"' --style compact

# Stream Xcode developer tools logs
log stream --predicate 'subsystem contains "com.apple.dt"' --style compact

# Watch DeviceSupport folder grow
while true; do
  echo "$(date +%H:%M:%S) $(du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/)"
  sleep 2
done

# Check all watchOS DeviceSupport folder sizes
du -sh ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*/

# Prevent Mac from sleeping
caffeinate -i &

# Reset CoreDevice tunnel daemons
sudo killall -9 remoted
sudo killall -9 companionappd

# Switch active Xcode version
sudo xcode-select -s /Applications/Xcode16.app/Contents/Developer

# Trigger symbol copy via xcodebuild
xcodebuild -scheme YourScheme -destination 'id=<UDID>' build

# Delete failed DeviceSupport entry to force device copy
rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport/"Watch* 26.3*"
```

---

## 17. Known Issues & Workarounds Summary

| Issue | Cause | Workaround |
|-------|-------|------------|
| `HTTP 403` on symbol download | Stale Apple ID session or CDN issue | Re-authenticate in Xcode Settings → Accounts; delete partial folder to force device copy |
| `CoreDeviceError 4000 / NWError 60` on any Watch | CoreDevice tunnel handshake fails over router | Enable iPhone Personal Hotspot → wait for Watch to appear → switch Mac back to regular WiFi → copy proceeds |
| Watch not appearing in devicectl | Trust not completed | Accept "Trust [Mac]" dialog on Watch |
| Symbol copy stuck at 0% | Slow wireless transfer or Watch sleeping | Put Watch on charger; enable Always On Display |
| `Code=1002 "No provider was found"` on every devicectl call | Xcode 26 bug with no provisioning context | Safely ignore — does not affect connectivity |
| Series 5 tunnel always `disconnected` in Xcode 26 | Likely Xcode 26 regression with arm64_32 | Use Xcode 16 for Series 5; file Feedback report |

---

## Device Inventory (from this session)

| Device | Model ID | OS | State |
|--------|----------|----|-------|
| Leo's Apple Watch S5 | Watch5,3 (arm64_32) | watchOS 10.6.2 | `available (paired)` ✅ — working via hotspot bootstrap |
| Leo's Apple Watch S7 | Watch6,8 | watchOS 26.x | `unavailable` (powered off) |
| Leo's Apple Watch Ultra | Watch7,5 | watchOS 26.3 | `unavailable` (powered off) — 403 on symbol download when on |
| Leo's iPhone | iPhone16,2 (iPhone 15 Pro Max) | iOS 26.x | `connected` ✅ |
| Leo's iPhone SE2 | iPhone12,8 | — | `unavailable` (powered off) |
| iPhone 12 mini | iPhone13,1 | — | `unavailable` (powered off) |
| iPhone 14 Pro | iPhone15,2 | — | `unavailable` (powered off) |

---

*Generated from a live debugging session — March 14–15, 2026*  
*Xcode 26.3 (Build 17C529) · macOS 26.3.1 (Build 25D2128)*
