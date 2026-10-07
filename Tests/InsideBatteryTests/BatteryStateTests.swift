import XCTest
@testable import InsideBattery

final class BatteryStateTests: XCTestCase {
    func testPercentageIsClampedToBatteryRange() {
        XCTAssertEqual(BatteryState(percentage: -2, isCharging: false).percentage, 0)
        XCTAssertEqual(BatteryState(percentage: 105, isCharging: false).percentage, 100)
    }

    func testAccessibilityLabelDescribesState() {
        XCTAssertEqual(BatteryState(percentage: 73, isCharging: false).accessibilityLabel, "Battery 73 percent")
        XCTAssertEqual(BatteryState(percentage: 73, isCharging: true).accessibilityLabel, "Battery 73 percent, charging")
        XCTAssertEqual(BatteryState.unavailable.accessibilityLabel, "Battery unavailable")
    }
}
