//
//  URLResponse+Ext.swift
//  FChucker
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//
import Foundation

extension URLResponse {
    func getStatusCode() -> Int {
        return (self as? HTTPURLResponse)?.statusCode ?? 0
    }
    
    func getHeaders() -> [AnyHashable: Any] {
        return (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }
}
