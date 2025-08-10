//
//  network_logger.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 3.08.2025.
//

import Foundation

public final class FChucker {
    public static func start() {
        URLProtocol.registerClass(FLogger.self)
    }
            
    static func stop() {
        URLProtocol.unregisterClass(FLogger.self)
    }
}

@Observable
final class FRequestStore {
    @MainActor static let shared = FRequestStore()
    private init() {}
    
    var requestList = [FModel]()
        
    func addRequst(_ request: FModel) {
        let isContains = self.requestList.contains(where: {$0.id == request.id})
        if (!isContains) {
            self.requestList.append(request)
        }
    }
    
    func clear() {
        self.requestList.removeAll()
    }
}
