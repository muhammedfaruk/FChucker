//
//  json_viewer.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 6.08.2025.
//

import SwiftUI

// MARK: - ViewModel
@MainActor
final class JSONViewerViewModel: ObservableObject {
    @Published var root: JSONNode?
    @Published var parseError: String?
    @Published var expanded: Set<UUID> = []

    func parse(data: Data) {
        parseError = nil
        root = nil
        expanded = []
        
        // Boş data kontrolü
        guard !data.isEmpty else {
            parseError = "Boş JSON verisi"
            return
        }
        
        Task {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                await MainActor.run {
                    let node = JSONNode(raw: obj)
                    self.root = node
                    if node.isContainer { 
                        self.expanded.insert(node.id) 
                    }
                }
            } catch {
                let raw = String(data: data, encoding: .utf8) ?? "Veri okunamadı"
                await MainActor.run {
                    self.parseError = "JSON parse hatası: \(error.localizedDescription)\n\nHam veri:\n\(raw)"
                }
            }
        }
    }

    func toggleAll(expand: Bool) {
        guard let root else { return }
        if expand {
            expanded = allContainerIDs(from: root)
        } else {
            expanded = []
            if root.isContainer { expanded.insert(root.id) }
        }
    }

    private func allContainerIDs(from node: JSONNode) -> Set<UUID> {
        var set: Set<UUID> = []
        func dfs(_ n: JSONNode) {
            if n.isContainer {
                set.insert(n.id)
                for c in n.children { dfs(c) }
            }
        }
        dfs(node)
        return set
    }

    struct FlatRow: Identifiable {
        let id: UUID
        let node: JSONNode
        let depth: Int
        let isExpanded: Bool
        let hasChildren: Bool
    }

    func flattened() -> [FlatRow] {
        guard let root else { return [] }
        var out: [FlatRow] = []
        func walk(_ n: JSONNode, _ depth: Int) {
            let isExp = expanded.contains(n.id)
            out.append(.init(id: n.id, node: n, depth: depth, isExpanded: isExp, hasChildren: n.isContainer && !n.children.isEmpty))
            if n.isContainer && isExp {
                for c in n.children { walk(c, depth + 1) }
            }
        }
        walk(root, 0)
        return out
    }
}

// MARK: - View
struct InteractiveJSONViewer: View {
    let data: Data
    @StateObject private var vm = JSONViewerViewModel()
    @State private var isAllExpanded: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: {
                    isAllExpanded.toggle()
                    vm.toggleAll(expand: isAllExpanded)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isAllExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        Text(isAllExpanded ? "Collapse All" : "Expand All")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }

                Button(action: copyJSON) {
                    Image(systemName: "doc.on.doc")
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }

                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.05))

            Divider()

            if let root = vm.root {
                ScrollView(showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(vm.flattened()) { row in
                            JSONRow(row: row) {
                                if row.node.isContainer {
                                    if vm.expanded.contains(row.node.id) {
                                        vm.expanded.remove(row.node.id)
                                    } else {
                                        vm.expanded.insert(row.node.id)
                                    }
                                }
                            }
                            .padding(.leading, CGFloat(row.depth) * 16)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.white)
            } else if let error = vm.parseError {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("JSON Not Found")
                            .font(.subheadline)
                            .foregroundColor(.red)                    
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ProgressView("JSON Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear { vm.parse(data: data) }
    }

    private func copyJSON() {
        UIPasteboard.general.string = String(data: data, encoding: .utf8)
    }
}

// MARK: - Row

private struct JSONRow: View {
    let row: JSONViewerViewModel.FlatRow
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if row.node.isContainer {
                Button(action: onToggle) {
                    Image(systemName: row.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                // hizalama için boş yer
                Image(systemName: "circle.fill")
                    .opacity(0)
                    .font(.system(size: 10))
            }

            // key
            if let k = row.node.key {
                Text(k)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                Text(":")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            // value preview
            Text(row.node.valuePreview)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(color(for: row.node))                
                .truncationMode(.tail)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if row.node.isContainer { onToggle() }
        }
    }

    private func color(for node: JSONNode) -> Color {
        switch node.kind {
        case .string: return .green
        case .number: return .orange
        case .bool:   return .purple
        case .null:   return .gray
        case .object, .array: return .blue
        }
    }
}
