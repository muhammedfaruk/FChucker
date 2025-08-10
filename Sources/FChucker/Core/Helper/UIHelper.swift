//
//  UIHelper.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//

import SwiftUI

final class FUIHelper {
    private init() {}
    static func statusConfig(for model: FModel) -> (color: Color, icon: String, text: String) {
        guard let code = model.statusCode else {
            return (.gray, "questionmark.circle.fill", "Unknown")
        }
        
        switch code {
        case 200..<300:
            return (.green, "checkmark.circle.fill", "Success")
        case 300..<400:
            return (.blue, "arrow.triangle.turn.up.right.circle.fill", "Redirect")
        case 400..<500:
            return (.orange, "exclamationmark.triangle.fill", "Client Error")
        case 500..<600:
            return (.red, "xmark.circle.fill", "Server Error")
        default:
            return (.gray, "questionmark.circle.fill", "Unknown")
        }
    }
    
    static func jsonTypeColor(value: Any) -> Color {
        if value is String {
            return .green
        } else if value is NSNumber {
            if CFBooleanGetTypeID() == CFGetTypeID(value as CFTypeRef) {
                return .purple
            }
            return .blue
        } else if value is NSNull {
            return .gray
        } else if value is [String: Any] || value is [Any] {
            return .primary
        }
        return .primary
    }
}
