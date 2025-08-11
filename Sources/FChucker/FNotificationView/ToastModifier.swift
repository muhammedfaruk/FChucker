//
//  ToastAlertModifier.swift
//  FChucker
//
//  Created by Muhammed Faruk Söğüt on 12.08.2025.
//


import SwiftUI

extension View {
    func toast(isPresented: Binding<Bool>,
                   message: String = "Copied ✅",
                   duration: TimeInterval = 1.5) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented,
                                        message: message,
                                        duration: duration))
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().strokeBorder(Color.secondary.opacity(0.2))
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.top, 12)
                    
                }
                .animation(.spring(), value: isPresented)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation(.easeOut) {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
