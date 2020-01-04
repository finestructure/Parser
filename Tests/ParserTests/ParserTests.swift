import XCTest
@testable import Parser

final class ParserTests: XCTestCase {

    func test_int() {
        XCTAssertEqual(Parser<Int>.int.run("123"), Match(result: 123, rest: ""))
        XCTAssertEqual(Parser<Int>.int.run("123abc"), Match(result: 123, rest: "abc"))
        XCTAssertEqual(Parser<Int>.int.run("abc123"), Match(result: nil, rest: "abc123"))
    }

    func test_char() {
        XCTAssertEqual(Parser<Character>.char.run("abc"), Match(result: "a", rest: "bc"))
        XCTAssertEqual(Parser<Character>.char.run("🎉✅😅"), Match(result: "🎉", rest: "✅😅"))
    }

    func test_char_in_CharacterSet() {
        XCTAssertEqual(Parser<Character>.char(in: .letters).run("abc123"), Match(result: "a", rest: "bc123"))
    }

    func test_literal() {
        let match = Parser<Void>.literal("ab").run("abc")
        XCTAssertNotNil(match.result)
        XCTAssertEqual(match.rest, "c")
    }

    func test_prefix() {
        XCTAssertEqual(Parser<String>.prefix(charactersIn: .letters).run("abc123"), Match(result: "abc", rest: "123"))
    }

    func test_string() {
        XCTAssertEqual(Parser<String>.string("123").run("123abc"), Match(result: "123", rest: "abc"))
    }
}
