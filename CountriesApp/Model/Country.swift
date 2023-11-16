//
//  Country.swift
//  CountriesApp
//
//  Created by Gytis Ptašinskas on 16/11/2023.
//

import Foundation


import Foundation

struct Country: Codable {
    let name: Name
    let capital: [String]?
    let region: String?
    let population: Int?
    let continents: [String]?
    let flags: Flags
}

struct Name: Codable {
    let common: String?
    let official: String?
}

struct Flags: Codable {
    let png: String?
}

