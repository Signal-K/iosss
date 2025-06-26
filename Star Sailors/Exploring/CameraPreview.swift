//
//  CameraPreview.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 24/6/2025.
//

import SwiftUI
import AVFoundation

struct CameraPreview: View {
    let session: AVCaptureSession

    var body: some View {
        #if targetEnvironment(simulator)
        // Fallback UI for Simulator
        ZStack {
            Color.black
            Text("Camera preview not available in Simulator")
                .foregroundColor(.white)
                .font(.caption)
        }
        #else
        CameraPreviewRepresentable(session: session)
        #endif
    }
}

#if !targetEnvironment(simulator)
struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
#endif
