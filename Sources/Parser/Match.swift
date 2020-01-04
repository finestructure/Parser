//
//  File.swift
//  
//
//  Created by Sven A. Schmidt on 04/01/2020.
//


public struct Match<A> {
    let result: A?
    let rest: Substring
}


extension Match: Equatable where A: Equatable {}
