//
//  CameraView.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 24/6/2025.
//

import SwiftUI
import AVFoundation

struct CameraScene: View {
    @State private var useCamera = true
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var scanLineOffset: CGFloat = 0
    @State private var isScanning = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.7), Color.red.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative bolts
            Group {
                topCornerBolt(.topLeading)
                topCornerBolt(.topTrailing)
            }

            // Circuit lines
            circuitLines

            VStack(spacing: 0) {
                // Header
                header

                Spacer()

                // Viewfinder
                viewfinder
                    .frame(maxWidth: 350)
                    .padding(.bottom, 32) // Prevent overlapping tab bar

                // Buttons
                controlButtons
                    .padding(.bottom, 12)

                // Camera toggle
                toggleControl
                    .padding(.bottom, 24)
            }
            .padding(.top, 40)
        }
    }

    // MARK: - Decorative Elements

    func topCornerBolt(_ alignment: Alignment) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 24, height: 24)
            .overlay(
                ZStack {
                    Rectangle().fill(Color.gray).frame(width: 12, height: 2)
                    Rectangle().fill(Color.gray).frame(width: 2, height: 12)
                }
            )
            .shadow(radius: 1)
            .alignmentGuide(alignment.horizontal) { _ in 24 }
            .alignmentGuide(alignment.vertical) { _ in 24 }
            .position(x: alignment == .topLeading ? 30 : UIScreen.main.bounds.width - 30, y: 40)
    }

    var circuitLines: some View {
        ZStack {
            Color.clear
            VStack {
                Spacer().frame(height: 60)
                HStack {
                    Spacer().frame(width: UIScreen.main.bounds.width / 4)
                    Rectangle().fill(Color.blue.opacity(0.2)).frame(width: 1, height: 40)
                    Spacer()
                    Rectangle().fill(Color.blue.opacity(0.2)).frame(width: 1, height: 60)
                    Spacer().frame(width: UIScreen.main.bounds.width / 4)
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Rectangle().fill(Color.blue.opacity(0.2)).frame(width: 1, height: 40)
                        .padding(.leading, UIScreen.main.bounds.width / 3)
                    Spacer()
                    Rectangle().fill(Color.blue.opacity(0.2)).frame(width: 1, height: 40)
                        .padding(.trailing, UIScreen.main.bounds.width / 3)
                }
                Spacer().frame(height: 40)
            }
        }
    }

    var header: some View {
        HStack {
            Circle()
                .fill(Color.white)
                .frame(width: 16, height: 16)
                .shadow(color: .white.opacity(0.6), radius: 8)

            Text("Scanner")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 8) {
                Circle().fill(Color.red).frame(width: 8, height: 8)
                Circle().fill(Color.yellow).frame(width: 8, height: 8)
                Circle().fill(Color.green).frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(30)
        .padding(.horizontal, 24)
    }

    var viewfinder: some View {
        ZStack {
            // Outer mechanical ring
            Circle()
                .fill(Color.gray.opacity(0.5))
                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                .overlay(
                    ForEach(0..<8) { i in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 10, height: 10)
                            .position(x: 150 + 140 * CGFloat(cos(Double(i) * .pi / 4)),
                                      y: 150 + 140 * CGFloat(sin(Double(i) * .pi / 4)))
                    }
                )
                .frame(width: 300, height: 300)

            // Inner glowing viewfinder
            Circle()
                .fill(Color.white)
                .overlay(Circle().stroke(Color.yellow, lineWidth: 4))
                .shadow(color: Color.yellow.opacity(0.5), radius: 10, x: 0, y: 0)
                .frame(width: 210, height: 210)
                .overlay(
                    Group {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                )
                .mask(Circle())

            // Scanning Line
            if isScanning {
                Rectangle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(height: 2)
                    .offset(y: scanLineOffset)
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            scanLineOffset = 100
                        }
                    }
            }
        }
    }

    var controlButtons: some View {
        HStack(spacing: 40) {
            Button(action: {
                showImagePicker = true
            }) {
                Text("Upload")
                    .frame(width: 100, height: 100)
                    .background(
                        RadialGradient(gradient: Gradient(colors: [.white, .gray]), center: .center, startRadius: 10, endRadius: 100)
                    )
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }

            Button(action: {
                isScanning.toggle()
            }) {
                Text("Scan")
                    .frame(width: 100, height: 100)
                    .background(
                        RadialGradient(gradient: Gradient(colors: [.white, .gray]), center: .center, startRadius: 10, endRadius: 100)
                    )
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
    }

    var toggleControl: some View {
        Button(action: {
            useCamera.toggle()
        }) {
            Text(useCamera ? "Use Upload" : "Use Camera")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(gradient: Gradient(colors: useCamera ? [Color.blue, Color.indigo] : [Color.orange, Color.red]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview

#Preview {
    CameraScene()
}
