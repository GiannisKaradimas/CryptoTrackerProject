//
//  WatchlistModel.swift
//  CryptoTracker
//
//  Created by ioannis.karadimas on 23/1/26.
//


import Foundation

struct WatchlistModel: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var coinIds: [String]
    let createdAt: Date

    init(id: UUID = UUID(), name: String, coinIds: [String] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.coinIds = coinIds
        self.createdAt = createdAt
    }
}
