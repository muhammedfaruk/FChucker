//
//  JSONNode.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//

import SwiftUI

final class JSONNode: Identifiable {
    enum Kind { case object, array, string(String), number(String), bool(Bool), null }

    let id = UUID()
    let key: String?
    private let raw: Any
    private(set) var kind: Kind
    private var _children: [JSONNode]?

    init(key: String? = nil, raw: Any) {
        self.key = key
        self.raw = raw

        if let dict = raw as? [String: Any] {
            self.kind = .object
            self._children = nil // lazy
        } else if let arr = raw as? [Any] {
            self.kind = .array
            self._children = nil // lazy
        } else if raw is NSNull {
            self.kind = .null
        } else if let s = raw as? String {
            self.kind = .string(s)
        } else if let b = raw as? Bool {
            self.kind = .bool(b)
        } else if let n = raw as? NSNumber {
            // tostring, int/double ayırt etmeden hızlı gösterim
            self.kind = .number(n.stringValue)
        } else {
            self.kind = .string(String(describing: raw))
        }
    }

    var isContainer: Bool {
        if case .object = kind { return true }
        if case .array = kind { return true }
        return false
    }

    var children: [JSONNode] {
        if let c = _children { return c }
        switch kind {
        case .object:
            let dict = (raw as? [String: Any]) ?? [:]
            let built = dict.keys.sorted().map { k in JSONNode(key: k, raw: dict[k]!) }
            _children = built
            return built
        case .array:
            let arr = (raw as? [Any]) ?? []
            let built = arr.enumerated().map { JSONNode(key: "[\($0.offset)]", raw: $0.element) }
            _children = built
            return built
        default:
            return []
        }
    }

    var valuePreview: String {
        switch kind {
        case .object: return "{…}"
        case .array:  return "[…]"
        case .string(let s):
            // Çok uzun stringleri kes
            let trimmed = s.count > 120 ? String(s.prefix(120)) + "…" : s
            return "\"\(trimmed)\""
        case .number(let n): return n
        case .bool(let b): return b ? "true" : "false"
        case .null: return "null"
        }
    }
}
