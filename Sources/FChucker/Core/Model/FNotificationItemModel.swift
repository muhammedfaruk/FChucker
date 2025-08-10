//
//  ToastItem.swift
//  FChucker
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//

import Foundation

struct FNotificationItemModel: Identifiable {
    public let id: UUID
    public let model: FModel
    public let appearTime: Date
    
    public init(id: UUID, model: FModel, appearTime: Date) {
        self.id = id
        self.model = model
        self.appearTime = appearTime
    }
}
