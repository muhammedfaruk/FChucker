//
//  FNetworkDetailView.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//

import SwiftUI

// MARK: - Request Info Component
private struct RequestInfoSection: View {
    let request: FModel
    
    var statusColor: Color {
        return FUIHelper.statusConfig(for: request).color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Request Information")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.bottom, 2)
            
            InfoRow(label: "Method:", value: request.method ?? "") {
                Text(request.method ?? "")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(FUIHelper.methodColor(for: request))
                    .cornerRadius(3)
            }
            
            InfoRow(label: "Status Code:") {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    Text("\(request.statusCode ?? 0)")
                        .font(.system(.caption, design: .monospaced))
                }
            }
            
            InfoRow(label: "URL:") {
                Text(request.url ?? "")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.blue)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            
            if let timestamp = request.timestamp {
                InfoRow(label: "Time:") {
                    HStack(spacing: 4) {
                        Text(timestamp, style: .date)
                            .font(.caption)
                        Text("at")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(timestamp, style: .time)
                            .font(.caption)
                    }
                }
            }
            
            if let headers = request.headers, !headers.isEmpty {
                InfoRow(label: "Headers:", value: "\(headers.count) headers") {
                    Text("\(headers.count) headers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Info Row Component
private struct InfoRow<Content: View>: View {
    let label: String
    let value: String?
    let content: () -> Content
    
    init(label: String, value: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.value = value
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
                .foregroundColor(.secondary)
            
            content()
            
            Spacer()
        }
        .padding(.vertical, 1)
    }
}

// MARK: - Headers Section Component
private struct HeadersSection: View {
    let headers: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Headers")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.bottom, 2)
            
            ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(key):")
                        .font(.system(.caption2, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(minWidth: 100, alignment: .leading)
                    
                    Text("\(value)")
                        .font(.system(.caption2, design: .monospaced))
                        .textSelection(.enabled)
                        .lineLimit(2)
                    
                    Spacer()
                }
                .padding(.vertical, 1)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct CurlSection: View {
    let curl: String
    @Binding var showCopiedMessage: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CURL")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)
                
                Spacer()
                
                Image(systemName: "document.on.document")
                    .foregroundStyle(Color.blue)
                    .onTapGesture {
                        UIPasteboard.general.string = curl
                        showCopiedMessage = true
                    }
            }
            
            
            Text(curl)
                .font(.system(.caption, design: .monospaced))
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - JSON Content Section Component
private struct JSONContentSection: View {
    let title: String
    let data: Data?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if let data = data {
                    Text("\(data.count) bytes")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if let data = data {
                InteractiveJSONViewer(data: data)
                    .frame(minHeight: 200)
            } else {
                Text("No data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FNetworkDetailView: View {
    let request: FModel
    
    @State private var selectedSegment = 0
    @State private var formattedResponse: String = ""
    @State private var isJSONValid: Bool = false
    @State private var showCopiedMessage: Bool = false
    
    private var segmentTitles: [String] {
        var titles = ["Request Detail"]
        if request.requestBodyData != nil {
            titles.append("Request Body")
        }
        if request.responseData != nil {
            titles.append("Response")
        }
        return titles
    }
    
    private var currentSegmentIndex: Int {
        // Map segment selection to actual content
        let selected = segmentTitles[selectedSegment]
        switch selected {
        case "Request Detail":
            return 0
        case "Request Body":
            return 1
        case "Response":
            return 2
        default:
            return 0
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("View", selection: $selectedSegment) {
                ForEach(0..<segmentTitles.count, id: \.self) { index in
                    Text(segmentTitles[index])
                        .font(.caption)
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(12)
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            
            // Content based on selection
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch segmentTitles[selectedSegment] {
                    case "Request Detail":
                        requestDetailView
                    case "Request Body":
                        requestBodyView
                    case "Response":
                        responseView
                    default:
                        EmptyView()
                    }
                }
                .padding(12)
            }
        }
        .navigationTitle("Request Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    let curl = request.generateCurlCommand()
                    UIPasteboard.general.string = curl
                    showCopiedMessage = true
                } label: {
                    Text("Copy cURL")
                }

            }
        }
        .toast(isPresented: $showCopiedMessage)
    }
    
    // MARK: - Request Detail View
    private var requestDetailView: some View {
        VStack(alignment: .leading, spacing: 12) {
            RequestInfoSection(request: request)
            
            if let headers = request.headers, !headers.isEmpty {
                HeadersSection(headers: headers)
            }
            
            if let curl = request.generateCurlCommand() {
                CurlSection(curl: curl, showCopiedMessage: $showCopiedMessage)
            }
        }
    }
    
    // MARK: - Request Body View
    private var requestBodyView: some View {
        JSONContentSection(title: "Request Body", data: request.requestBodyData)
    }
    
    // MARK: - Response View
    private var responseView: some View {
        JSONContentSection(title: "Response", data: request.responseData)
    }
}
