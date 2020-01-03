//
//  Parser.swift
//
//
//  Created by Sven A. Schmidt on 29/12/2019.
//

public struct Parser<A> {
    let run: (inout Substring) -> A?

    public init(_ run: @escaping (inout Substring) -> A?) {
        self.run = run
    }
}

public let int = Parser<Int> { str in
  let prefix = str.prefix(while: { $0.isNumber })
  let match = Int(prefix)
  str.removeFirst(prefix.count)
  return match
}

public let double = Parser<Double> { str in
  let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
  let match = Double(prefix)
  str.removeFirst(prefix.count)
  return match
}

public let char = Parser<Character> { str in
  guard !str.isEmpty else { return nil }
  return str.removeFirst()
}

public func literal(_ p: String) -> Parser<Void> {
  return Parser<Void> { str in
    guard str.hasPrefix(p) else { return nil }
    str.removeFirst(p.count)
    return ()
  }
}

public func always<A>(_ a: A) -> Parser<A> {
  return Parser<A> { _ in a }
}

extension Parser {
  public static var never: Parser {
    return Parser { _ in nil }
  }
}

extension Parser {
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
}

public func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
  return Parser<(A, B)> { str -> (A, B)? in
    let original = str
    guard let matchA = a.run(&str) else { return nil }
    guard let matchB = b.run(&str) else {
      str = original
      return nil
    }
    return (matchA, matchB)
  }
}


public func zip<A, B, C>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>
  ) -> Parser<(A, B, C)> {
  return zip(a, zip(b, c))
    .map { a, bc in (a, bc.0, bc.1) }
}

public func zip<A, B, C, D>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>
  ) -> Parser<(A, B, C, D)> {
  return zip(a, zip(b, c, d))
    .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

public func zip<A, B, C, D, E>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>,
  _ e: Parser<E>
  ) -> Parser<(A, B, C, D, E)> {

  return zip(a, zip(b, c, d, e))
    .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

public func zip<A, B, C, D, E, F>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>,
  _ e: Parser<E>,
  _ f: Parser<F>
  ) -> Parser<(A, B, C, D, E, F)> {
  return zip(a, zip(b, c, d, e, f))
    .map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}

public func zip<A, B, C, D, E, F, G>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>,
  _ e: Parser<E>,
  _ f: Parser<F>,
  _ g: Parser<G>
  ) -> Parser<(A, B, C, D, E, F, G)> {
  return zip(a, zip(b, c, d, e, f, g))
    .map { a, bcdefg in (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5) }
}




extension Parser {
  public func run(_ str: String) -> (match: A?, rest: Substring) {
    var str = str[...]
    let match = self.run(&str)
    return (match, str)
  }
}


public func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
  return Parser<Substring> { str in
    let prefix = str.prefix(while: p)
    str.removeFirst(prefix.count)
    return prefix
  }
}

public let zeroOrMoreSpaces = prefix(
  while: { $0 == " " })
  .map { _ in () }
//  Parser<Void> { str -> Void? in
//  let prefix = str.prefix(while: { $0 == " " })
//  str.removeFirst(prefix.count)
//  return ()
//}

public let oneOrMoreSpaces = prefix(
  while: { $0 == " " })
  .flatMap {
    $0.isEmpty
      ? .never
      : always(())
}
//  Parser<Void> { str -> Void? in
//  let prefix = str.prefix(while: { $0 == " " })
//  guard !prefix.isEmpty else { return nil }
//  str.removeFirst(prefix.count)
//  return ()
//}
