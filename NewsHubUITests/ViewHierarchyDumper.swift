//
//  ViewHierarchyDumper.swift
//  NewsHubUITests
//
//  Add this file to your UITests target.
//  Run with xcodebuild and pass:
//    ROUTE_DEEPLINK='newshub://route?...'
//    VERIFY_ID='some.accessibility.id'
//    UI_MAP_OUT='/tmp/ui-map.json'   (optional; defaults to /tmp/ui-map.json)
//

import XCTest

final class ViewHierarchyDumper: XCTestCase {

    /// Single entry point; run with:
    /// xcodebuild test -project NewsHub.xcodeproj -scheme NewsHubUITests \
    ///   -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
    ///   -only-testing NewsHubUITests/ViewHierarchyDumper/test_dump \
    ///   ROUTE_DEEPLINK='newshub://transfer?step=amount' \
    ///   VERIFY_ID='transfer.amountField' \
    ///   UI_MAP_OUT='/tmp/ui-map.json' -quiet
    func test_dump() {
        // 1) Read inputs supplied by xcodebuild (inline env)
        let env = ProcessInfo.processInfo.environment
        guard let deeplink = env["ROUTE_DEEPLINK"], !deeplink.isEmpty else {
            XCTFail("Missing env ROUTE_DEEPLINK"); return
        }
        guard let verifyId = env["VERIFY_ID"], !verifyId.isEmpty else {
            XCTFail("Missing env VERIFY_ID"); return
        }
        let outPath = env["UI_MAP_OUT"] ?? "/tmp/ui-map.json"

        // 2) Launch app with *lowercase* -deeplink (matches NewsHubApp)
        let app = XCUIApplication()
        app.launchArguments += ["-UITestMode", "1", "-deeplink", deeplink]
        app.launch()

        // 3) Verify we landed on the intended screen
        let anchor = app.descendants(matching: .any)[verifyId].firstMatch
        XCTAssertTrue(anchor.waitForExistence(timeout: 8),
                      "Verify element not found: \(verifyId)")

        // 4) Dump runtime accessibility tree → minimal JSON
        let rawTree = app.debugDescription
        let json = Self.normalize(debugDescription: rawTree)

        // 5) Attach to test report & persist for the agent
        add(XCTAttachment(string: json))
        Self.ensureParentDirectoryExists(for: outPath)
        do {
            try json.write(toFile: outPath, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Failed to write UI map to \(outPath): \(error)")
        }
    }

    // MARK: - Helpers

    /// Minimal normalizer: capture role/type + identifier (+label, hittable).
    private static func normalize(debugDescription: String) -> String {
        struct UIEl: Codable { let id: String; let type: String; let label: String?; let hittable: Bool? }
        struct UIMap: Codable { let capturedAt: String; let elements: [UIEl] }

        var elements: [UIEl] = []

        for line in debugDescription.split(separator: "\n") {
            // Example start tokens: "Button,", "TextField,", "StaticText,", ...
            guard let type = line.split(separator: ",", maxSplits: 1).first
                    .map({ String($0).trimmingCharacters(in: .whitespaces) }),
                  let id = extract(line, after: "identifier: "), !id.isEmpty
            else { continue }

            let label = extract(line, after: "label: ")
            let hittable = extract(line, after: "isHittable: ").flatMap(Bool.init)

            elements.append(.init(id: id, type: type, label: label, hittable: hittable))
        }

        let map = UIMap(
            capturedAt: ISO8601DateFormatter().string(from: Date()),
            elements: elements
        )
        let data = try! JSONEncoder().encode(map)
        return String(data: data, encoding: .utf8)!
    }

    /// Extracts the value immediately following `key` until the next comma (or end of line).
    private static func extract(_ line: Substring, after key: String) -> String? {
        guard let r = line.range(of: key) else { return nil }
        let tail = line[r.upperBound...]
        let stop = tail.firstIndex(of: ",") ?? tail.endIndex
        let v = String(tail[..<stop]).trimmingCharacters(in: .whitespacesAndNewlines)
        return v.isEmpty ? nil : v
    }

    /// Ensure parent directory exists for a given path.
    private static func ensureParentDirectoryExists(for path: String) {
        let url = URL(fileURLWithPath: path)
        let dir = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // Best-effort; writing will fail loudly if this didn't work
        }
    }
}
