//
//  File.swift
//  
//
//  Created by Sven A. Schmidt on 04/01/2020.
//


public struct Match<A> {
    public let result: A?
    public let rest: Substring

    public init(result: A?, rest: Substring) {
        self.result = result
        self.rest = rest
    }
}


extension Match: Equatable where A: Equatable {}
