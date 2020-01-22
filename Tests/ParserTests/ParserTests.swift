import XCTest
@testable import Parser

final class ParserTests: XCTestCase {

    func test_int() {
        XCTAssertEqual(Parser.int.run("123"), Match(result: 123, rest: ""))
        XCTAssertEqual(Parser.int.run("123abc"), Match(result: 123, rest: "abc"))
        XCTAssertEqual(Parser.int.run("abc123"), Match(result: nil, rest: "abc123"))
    }

    func test_char() {
        XCTAssertEqual(Parser.char.run("abc"), Match(result: "a", rest: "bc"))
        XCTAssertEqual(Parser.char.run("🎉✅😅"), Match(result: "🎉", rest: "✅😅"))
    }

    func test_CharacterSet_contains_character() {
        XCTAssertTrue(CharacterSet.decimalDigits.contains(character: "3"))
        XCTAssertFalse(CharacterSet.decimalDigits.contains(character: "a"))
        XCTAssertTrue(CharacterSet(charactersIn: "👩‍👩‍👧‍👦").contains(character: "👩‍👩‍👧‍👦"))
        XCTAssertFalse(CharacterSet(charactersIn: "👩").contains(character: "👩‍👩‍👧‍👦"))
        XCTAssertFalse(CharacterSet(charactersIn: "👩‍👩‍👧‍👦").contains(character: "👩"))
    }

    func test_char_in_CharacterSet() {
        XCTAssertEqual(Parser.char(in: .letters).run("abc123"), Match(result: "a", rest: "bc123"))
    }

    func test_literal() {
        let match = Parser.literal("ab").run("abc")
        XCTAssertNotNil(match.result)
        XCTAssertEqual(match.rest, "c")
    }

    func test_prefix_charactersIn() {
        XCTAssertEqual(Parser.prefix(charactersIn: .letters).run("abc123"), Match(result: "abc", rest: "123"))
    }

    func test_prefix_while() {
        XCTAssertEqual(Parser.prefix(while: { $0 == " "}).run("   123"), Match(result: "   ", rest: "123"))
    }

    func test_prefix_upTo() {
        XCTAssertEqual(Parser.prefix(upTo: "--").run("abc--def"), Match(result: "abc", rest: "--def"))
    }

    func test_string() {
        XCTAssertEqual(Parser.string("123").run("123abc"), Match(result: "123", rest: "abc"))
    }

    func test_map() {
        let p = Parser.int.map { $0 + 1 }
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
        XCTAssertEqual(Parser.never.run("foo"), Match<String>(result: nil, rest: "foo"))
        XCTAssertEqual(Parser.never.run(""), Match<Int>(result: nil, rest: ""))
    }

    func test_end() {
        XCTAssertNotNil(Parser.end.run("").result)
        XCTAssertNil(Parser.end.run("foo").result)
        XCTAssertEqual(Parser.end.run("foo").rest, "foo")
    }

    func test_flatMap() {
        let evenInt = Parser.int.flatMap { $0.isMultiple(of: 2) ? .always($0) : .never }
        XCTAssertEqual(evenInt.run("12"), Match(result: 12, rest: ""))
        XCTAssertEqual(evenInt.run("13"), Match(result: nil, rest: "13"))
    }

    func test_exhaustive() {
        let p = Parser.int.exhaustive
        XCTAssertEqual(p.run("123"), Match(result: 123, rest: ""))
        XCTAssertEqual(p.run("123 "), Match(result: nil, rest: "123 "))
    }

    func test_oneOf() {
        let p = oneOf([.string("foo"), .string("bar")])
        XCTAssertEqual(p.run("foo ..."), Match(result: "foo", rest: " ..."))
        XCTAssertEqual(p.run("bar ..."), Match(result: "bar", rest: " ..."))
        XCTAssertEqual(p.run("baz ..."), Match(result: nil, rest: "baz ..."))
    }
}
