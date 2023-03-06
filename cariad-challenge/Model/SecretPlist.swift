//
//  SecretPlist.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 06/03/2023.
//

import Foundation

public struct SecretPlist {
    static func apiKey(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let info = NSDictionary(contentsOfFile: path),
              let apiKey = info[key] as? String else {
            fatalError("Could not load Secrets.plist with \(key)")
        }
        return apiKey
    }
}
