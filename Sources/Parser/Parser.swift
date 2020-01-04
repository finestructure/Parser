//
//  Parser.swift
//
//
//  Created by Sven A. Schmidt on 29/12/2019.
//
//  Based on Pointfree series on Parsers
//
//  https://www.pointfree.co/episodes/ep56-what-is-a-parser-part-1 and following episodes
//

import Foundation


public struct Parser<A> {
    public let run: (inout Substring) -> A?

    public init(_ run: @escaping (inout Substring) -> A?) {
        self.run = run
    }

    public func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
      return Parser<B> { str -> B? in
        self.run(&str).map(f)
      }
    }

    public func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        return Parser<B> { str -> B? in
            let original = str
            let matchA = self.run(&str)
            let parserB = matchA.map(f)
            guard let matchB = parserB?.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }

    public func run(_ str: String) -> Match<A> {
      var str = str[...]
      let res = self.run(&str)
      return Match(result: res, rest: str)
    }

    public static var end: Parser<Void> {
        Parser<Void> { $0.isEmpty ? () : nil }
    }

    public static func appendEnd(_ p: Parser<A>) -> Parser<A> {
        zip(p, .end).flatMap { a, _ in always(a) }
    }
}


// MARK:- basic parsers


extension Parser {

    public static var int: Parser<Int> {
        Parser<Int> { str in
            let prefix = str.prefix(while: { $0.isNumber })
            let match = Int(prefix)
            str.removeFirst(prefix.count)
            return match
        }
    }

    public static var char: Parser<Character> {
        Parser<Character> { str in
            guard !str.isEmpty else { return nil }
            return str.removeFirst()
        }
    }

    public static func char(in characterSet: CharacterSet) -> Parser<Character> {
        return Parser<Character> { str in
            guard let first = str.first, characterSet.contains(character: first) else { return nil }
            return str.removeFirst()
        }
    }

    public static func literal(_ p: String) -> Parser<Void> {
      return Parser<Void> { str in
        guard str.hasPrefix(p) else { return nil }
        str.removeFirst(p.count)
        return ()
      }
    }

    public static func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
      return Parser<Substring> { str in
        let prefix = str.prefix(while: p)
        str.removeFirst(prefix.count)
        return prefix
      }
    }

    public static func prefix(charactersIn characterSet: CharacterSet) -> Parser<Substring> {
        return prefix(while: { characterSet.contains(character: $0) })
    }

    public static func prefix(upTo p: String) -> Parser<Substring> {
      return Parser<Substring> { str in
        guard let range = str.range(of: p) else {
            let match = str[...]
            str = ""
            return match
        }
        let match = str[..<range.lowerBound]
        str = str[range.lowerBound...]
        return match
      }
    }

    public static func string(_ p: String) -> Parser<String> {
      return Parser<String> { str in
        guard str.hasPrefix(p) else { return nil }
        str.removeFirst(p.count)
        return p
      }
    }

}


extension Parser {

    public static func always<A>(_ a: A) -> Parser<A> {
        return Parser<A> { _ in a }
    }

    public static var never: Parser {
        return Parser { _ in nil }
    }
}


public func oneOf<A>(
  _ ps: [Parser<A>]
  ) -> Parser<A> {
  return Parser<A> { str -> A? in
    for p in ps {
      if let match = p.run(&str) {
        return match
      }
    }
    return nil
  }
}




public func shortestOf<A>(_ ps: [Parser<A>]) -> Parser<A> {
    return Parser<A> { str -> A? in
        var shortest: A? = nil
        var longestRestLength = -1
        for p in ps {
            var orig = str
            let m = p.run(&orig)
            if orig.count > longestRestLength {
                longestRestLength = orig.count
                shortest = m
            }
        }
        str.removeFirst(str.count - longestRestLength)
        return shortest
    }
}

