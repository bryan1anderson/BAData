import XCTest
@testable import BAData

final class BADataTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BAData().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
