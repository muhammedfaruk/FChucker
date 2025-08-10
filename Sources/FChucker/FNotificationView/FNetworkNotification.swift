//
//  ToastView.swift
//  FChucker-Test
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//

import SwiftUI


public extension View {
    func networkToasts(duration: Double = 2.5) -> some View {
        self.modifier(NetworkToastOverlay(duration: duration))
    }
}



struct NetworkToastOverlay: ViewModifier {
    private let fRequestStore = FRequestStore.shared
    @State private var showNetworkView = false
    @State private var activeToasts: [FNotificationItemModel] = []
    @State private var lastProcessedId: UUID?
    
    var duration: Double
    
    init(duration: Double) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    ForEach(Array(activeToasts.prefix(4).reversed().enumerated()), id: \.element.id) { index, toast in
                        FNetworkNotification(
                            model: toast.model,
                            duration: duration,
                            showNetworkView: $showNetworkView,
                            onDismiss: {
                                removeToast(id: toast.id)
                            }
                        )
                        .id(toast.id)
                        .offset(y: CGFloat(index * -16)) // Clean offset
                        .scaleEffect(1 - (CGFloat(index) * 0.025)) // Subtle scale
                        .opacity(1 - (Double(index) * 0.08)) // Gentle opacity
                        .zIndex(Double(100 - index)) // Ensure proper layering
                    }
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 16)

            }
            .sheet(isPresented: $showNetworkView) {
                FNetworkView()
            }
            .onChange(of: fRequestStore.requestList, { oldModel, newModel in
                checkForNewRequests()
            })
    }
    
    private func checkForNewRequests() {
        // Check if there's a new request that we haven't processed yet
        if let lastRequest = fRequestStore.requestList.last,
           lastRequest.id != lastProcessedId {
            
            // Add the new toast
            let newToast = FNotificationItemModel(
                id: lastRequest.id,
                model: lastRequest,
                appearTime: Date()
            )
            
            withAnimation {
                activeToasts.append(newToast)
            }
            
            lastProcessedId = lastRequest.id
            
            // Keep only the last 5 toasts to prevent overflow
            if activeToasts.count > 5 {
                activeToasts.removeFirst()
            }
        }
    }
    
    private func removeToast(id: UUID) {
        withAnimation {
            activeToasts.removeAll { $0.id == id }
        }
    }
}

struct FNetworkNotification: View {
    
    var model: FModel
    var duration: Double
    @Binding var showNetworkView: Bool
    var onDismiss: () -> Void
    
    @State private var isShowing = false
    @State private var offset: CGFloat = 100
    @State private var isPressed = false
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    
    init(model: FModel, duration: Double, showNetworkView: Binding<Bool>, onDismiss: @escaping () -> Void) {
        self.model = model
        self.duration = duration
        self._showNetworkView = showNetworkView
        self.onDismiss = onDismiss
    }
    
    private var statusConfig: (color: Color, icon: String, text: String) {
        return FUIHelper.statusConfig(for: model)
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                statusConfig.color.opacity(0.9),
                statusConfig.color.opacity(0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: statusConfig.icon)
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.white.opacity(0.2))
                )
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // URL and Status Code
                HStack(spacing: 8) {
                    Text(model.url ?? "Unknown URL")
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    // Status Code Badge
                    if let code = model.statusCode {
                        Text("\(code)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.25))
                            )
                    }
                }
                
                // Method and Status Text
                HStack(spacing: 6) {
                    if let method = model.method {
                        Label {
                            Text(method)
                                .font(.system(size: 11, weight: .medium))
                        } icon: {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .font(.system(size: 10))
                        }
                    }
                    
                    Text("•")
                        .opacity(0.5)
                    
                    Text(statusConfig.text)
                        .font(.system(size: 11))
                        .opacity(0.9)
                    
                    Spacer()
                    
                    // Tap indicator or close button
                    if isDragging {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .opacity(0.7)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .opacity(0.7)
                            .scaleEffect(isPressed ? 0.8 : 1)
                    }
                }
                .opacity(0.95)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: statusConfig.color.opacity(0.3), radius: 12, x: 0, y: 6)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .foregroundStyle(.white)
        .scaleEffect(isPressed ? 0.95 : (isShowing ? 1 : 0.9))
        .offset(x: dragOffset.width, y: offset + dragOffset.height)
        .opacity(isShowing ? (isDragging ? 0.8 : 1) : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)) {
                isShowing = true
                offset = 0
            }
            
            // Auto dismiss after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                dismissToast()
            }
        }
        .onTapGesture {
            // Haptic feedback for tap
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                showNetworkView = true
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring()) {
                        isDragging = true
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        // If dragged far enough, dismiss
                        if abs(value.translation.width) > 100 || value.translation.height > 50 {
                            dismissToast()
                        } else {
                            // Snap back to position
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
    }
    
    private func dismissToast() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isShowing = false
            offset = 100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
