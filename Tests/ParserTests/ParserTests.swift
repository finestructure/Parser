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

    func test_prefix_charactersIn() {
        XCTAssertEqual(Parser<String>.prefix(charactersIn: .letters).run("abc123"), Match(result: "abc", rest: "123"))
    }

    func test_prefix_while() {
        XCTAssertEqual(Parser<String>.prefix(while: { $0 == " "}).run("   123"), Match(result: "   ", rest: "123"))
    }

    func test_prefix_upTo() {
        XCTAssertEqual(Parser<String>.prefix(upTo: "--").run("abc--def"), Match(result: "abc", rest: "--def"))
    }

    func test_string() {
        XCTAssertEqual(Parser<String>.string("123").run("123abc"), Match(result: "123", rest: "abc"))
    }

    func test_map() {
        let p = Parser<Int>.int.map { $0 + 1 }
        XCTAssertEqual(p.run("1"), Match(result: 2, rest: ""))
    }

    func test_zip() {
        struct Version: Equatable {
            let major: Int
            let minor: Int
        }
        let p = zip(.int, .literal("."), .int).map { Version(major: $0.0, minor: $0.2) }
        XCTAssertEqual(p.run("1.2"), Match<Version>(result: Version(major: 1, minor: 2), rest: ""))
    }

    func test_always() {
        XCTAssertEqual(Parser<String>.always("a").run("foo"), Match(result: "a", rest: "foo"))
        XCTAssertEqual(Parser<Int>.always(123).run("foo"), Match(result: 123, rest: "foo"))
        XCTAssertEqual(Parser<Int>.always(123).run(""), Match(result: 123, rest: ""))
    }

    func test_never() {
        XCTAssertEqual(Parser<String>.never.run("foo"), Match<String>(result: nil, rest: "foo"))
        XCTAssertEqual(Parser<Int>.never.run(""), Match<Int>(result: nil, rest: ""))
    }

    // appendEnd

}
