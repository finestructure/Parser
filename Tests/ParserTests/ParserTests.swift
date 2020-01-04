import XCTest
@testable import Parser

final class ParserTests: XCTestCase {

    func test_int() {
        XCTAssertEqual(int.run("123"), Match(result: 123, rest: ""))
        XCTAssertEqual(int.run("123abc"), Match(result: 123, rest: "abc"))
        XCTAssertEqual(int.run("abc123"), Match(result: nil, rest: "abc123"))
    }

    func test_char() {
        XCTAssertEqual(char.run("abc"), Match(result: "a", rest: "bc"))
        XCTAssertEqual(char.run("🎉✅😅"), Match(result: "🎉", rest: "✅😅"))
    }

    func test_literal() {
        let match = literal("ab").run("abc")
        XCTAssertNotNil(match.result)
        XCTAssertEqual(match.rest, "c")
    }

}
