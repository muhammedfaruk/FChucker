//
//  network_logger.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 3.08.2025.
//

import Foundation

public final class FChucker {
    public static func start() {
        URLSessionConfiguration.implementFChucker()
        URLProtocol.registerClass(FLogger.self)
    }
    
    public static func stop() {
        URLProtocol.unregisterClass(FLogger.self)
    }
}


final class FRequestStore: ObservableObject {
    @MainActor static let shared = FRequestStore()
    private init() {}
    
    @Published var requestList = [FModel]()
        
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
