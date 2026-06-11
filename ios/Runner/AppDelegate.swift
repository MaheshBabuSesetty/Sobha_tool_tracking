import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  private let securityChannelName = "com.sobha.rfid.tool.tracking/security"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Required for Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Security MethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: securityChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { call, result in
        switch call.method {

        case "isRootedOrJailbroken":
          result(SecurityChecks.isJailbroken())

        case "isHookedOrInstrumented":
          result(SecurityChecks.isHookedOrInstrumented())

        case "isDebuggerAttached":
          result(SecurityChecks.isDebuggerAttached())

        case "isDeveloperMode":
          // iOS has no reliable, public "developer mode enabled" flag like Android.
          result(false)

        case "isEmulator":
          result(SecurityChecks.isSimulator())

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - Security Checks (App Store Safe)

final class SecurityChecks {

  // Simulator detection
  static func isSimulator() -> Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
  }

  // Jailbreak / rootless (Dopamine) detection (multi-indicator)
  static func isJailbroken() -> Bool {
#if targetEnvironment(simulator)
    return false
#else
    // 1) Sandbox escape: write outside container (strong indicator)
    if canWriteOutsideSandbox() { return true }

    // 2) Known jailbreak artifacts (include rootless paths)
    let suspiciousPaths = [
      "/Applications/Cydia.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/bin/bash",
      "/usr/sbin/sshd",
      "/etc/apt",
      "/private/var/lib/apt/",
      "/var/jb",              // common in rootless jailbreaks
      "/private/var/jb",
      "/Library/PreferenceBundles"
    ]

    for path in suspiciousPaths {
      if FileManager.default.fileExists(atPath: path) { return true }
    }

    return false
#endif
  }

  // Instrumentation / injection heuristic (best-effort, client-side)
  static func isHookedOrInstrumented() -> Bool {
#if targetEnvironment(simulator)
    return false
#else
    // DYLD injection environment variable
    if let dyld = getenv("DYLD_INSERT_LIBRARIES") {
      let v = String(cString: dyld)
      if !v.isEmpty { return true }
    }
    return false
#endif
  }

  // Debugger detection using sysctl (App Store safe)
  static func isDebuggerAttached() -> Bool {
#if targetEnvironment(simulator)
    return false
#else
    var info = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout<kinfo_proc>.stride

    let sysctlResult = mib.withUnsafeMutableBufferPointer { mibPtr in
      sysctl(mibPtr.baseAddress, 4, &info, &size, nil, 0)
    }

    if sysctlResult != 0 { return false }

    return (info.kp_proc.p_flag & P_TRACED) != 0
#endif
  }

  // MARK: - Helpers

  // Attempts writing outside sandbox. If it succeeds => compromised.
  private static func canWriteOutsideSandbox() -> Bool {
    let testPath = "/private/sobha_rfid_tool_jb_test.txt"
    do {
      try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
      try FileManager.default.removeItem(atPath: testPath)
      return true
    } catch {
      return false
    }
  }
}