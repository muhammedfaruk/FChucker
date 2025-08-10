//
//  URLRequest+Ext.swift
//  FChucker
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//
import Foundation

extension URLRequest {
    func readBodyStream() -> Data? {
        let stream = self.httpBodyStream
        guard let stream else {
            return nil
        }
        stream.open()
        defer { stream.close() }
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        var data = Data()
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else {
                break
            }
        }
        
        return data.isEmpty ? nil : data
    }
    
    func getHeaders() -> [String: Any] {
        return allHTTPHeaderFields ?? [:]
    }
}
