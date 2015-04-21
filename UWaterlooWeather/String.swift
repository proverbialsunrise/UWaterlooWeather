//
//  String.swift
//  UWaterlooWeather
//
//  Created by Daniel Johnson on 4/21/15.
//  Copyright (c) 2015 Daniel Johnson. All rights reserved.
//

import Foundation

public extension String {

    func trim() -> String? {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    //Trim whitespace and return an optional Int
    func trimAndToInt() -> Int? {
        let trimmedString = self.trim()
        let number = NSNumberFormatter().numberFromString(trimmedString!)
        if (number != nil) {
            return number?.integerValue
        } else {
            return nil
        }
    }
    
    
    //Trim whitespace and return a float
    func trimAndToFloat() -> Float? {
        let trimmedString = self.trim()
        let number = NSNumberFormatter().numberFromString(trimmedString!)
        if (number != nil) {
            return number?.floatValue
        } else {
            return nil
        }
    }
    
}