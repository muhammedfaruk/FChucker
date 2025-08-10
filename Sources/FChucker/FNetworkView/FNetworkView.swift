//
//  FNetworkView.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//

import SwiftUI

struct FNetworkView: View {
    private var fRequestStore = FRequestStore.shared
    
    var body: some View {
        NavigationStack {
            NetworkRequestsList(requests: fRequestStore.requestList.reversed())
                .navigationTitle("Network Requests")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        ClearAllButton {
                            fRequestStore.clear()
                        }
                    }
                }
        }
    }
}

struct NetworkRequestsList: View {
    let requests: [FModel]
    
    var body: some View {
        List(requests, id: \.id) { request in
            NavigationLink(destination: FNetworkDetailView(request: request)) {
                RequestListItem(request: request)
            }
        }
    }
}

struct RequestListItem: View {
    let request: FModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            RequestHeaderRow(request: request)
            RequestURLText(url: request.url)
        }
        .padding(.vertical, 4)
    }
}

struct RequestHeaderRow: View {
    let request: FModel
    
    var body: some View {
        HStack {
            RequestMethodBadge(method: request.method, request: request)
            RequestStatusIndicator(request: request)
            Spacer()
            RequestTimestamp(timestamp: request.timestamp)
        }
    }
}

struct RequestMethodBadge: View {
    let method: String?
    let request: FModel
    
    var body: some View {
        Text(method ?? "")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(FUIHelper.statusConfig(for: request).color)
            .cornerRadius(4)
    }
}

struct RequestStatusIndicator: View {
    let request: FModel
    
    var body: some View {
        if let statusCode = request.statusCode {
            HStack(spacing: 4) {
                Circle()
                    .fill(FUIHelper.statusConfig(for: request).color)
                    .frame(width: 6, height: 6)
                Text("\(statusCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RequestTimestamp: View {
    let timestamp: Date?
    
    var body: some View {
        if let timestamp = timestamp {
            Text(timestamp, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RequestURLText: View {
    let url: String?
    
    var body: some View {
        Text(url ?? "")
            .font(.system(.footnote, design: .monospaced))
            .lineLimit(2)
            .foregroundColor(.primary)
    }
}

struct ClearAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Clear All")
        }
    }
}
