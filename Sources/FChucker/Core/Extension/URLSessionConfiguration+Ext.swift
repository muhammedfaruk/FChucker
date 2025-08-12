//
//  URLSessionConfiguration.swift
//  FChucker
//
//  Created by Muhammed Faruk Söğüt on 12.08.2025.
//

import Foundation

extension URLSessionConfiguration {
    
    static func implementFChucker() {
        swizzleDefaultConfiguration()
        swizzleEphemeralConfiguration()
    }
    
    private static func swizzleDefaultConfiguration() {
        let targetClass: AnyClass = object_getClass(self)!
        
        let originalSelector = #selector(getter: URLSessionConfiguration.default)
        let swizzledSelector = #selector(getter: URLSessionConfiguration.default_FCSwizzled)
        
        let originalMethod = class_getClassMethod(targetClass, originalSelector)!
        let swizzledMethod = class_getClassMethod(targetClass, swizzledSelector)!
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    private static func swizzleEphemeralConfiguration() {
        let targetClass: AnyClass = object_getClass(self)!
        
        let originalSelector = #selector(getter: URLSessionConfiguration.ephemeral)
        let swizzledSelector = #selector(getter: URLSessionConfiguration.ephemeral_FCSwizzled)
        
        let originalMethod = class_getClassMethod(targetClass, originalSelector)!
        let swizzledMethod = class_getClassMethod(targetClass, swizzledSelector)!
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc private class var default_FCSwizzled: URLSessionConfiguration {
        get {
            let configuration = URLSessionConfiguration.default_FCSwizzled
                        
            var protocols: [AnyClass] = configuration.protocolClasses ?? []
            
            if !protocols.contains(where: { $0 == FLogger.self }) {
                protocols.insert(FLogger.self, at: 0)
                configuration.protocolClasses = protocols
            }
            
            return configuration
        }
    }
    
    @objc private class var ephemeral_FCSwizzled: URLSessionConfiguration {
        get {
            let configuration = URLSessionConfiguration.ephemeral_FCSwizzled
                        
            var protocols: [AnyClass] = configuration.protocolClasses ?? []
            
            if !protocols.contains(where: { $0 == FLogger.self }) {
                protocols.insert(FLogger.self, at: 0)
                configuration.protocolClasses = protocols
            }
            
            return configuration
        }
    }
}
