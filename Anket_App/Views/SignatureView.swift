//
//  SignatureView.swift
//  Anket_App
//
//  Created by zehra özer on 18.05.2025.
//

import SwiftUI
struct SignatureView: View {
    @Binding var points: [CGPoint]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white

                Path { path in
                    var previousPoint: CGPoint? = nil
                    for point in points {
                        if point == .zero {
                            previousPoint = nil // öncekinden devamı iptal et
                        } else {
                            if let prev = previousPoint {
                                path.move(to: prev)
                                path.addLine(to: point)
                            }
                            previousPoint = point
                        }
                    }
                }
                .stroke(Color.black, lineWidth: 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = value.location
                        if geometry.frame(in: .local).contains(point) {
                            points.append(point)
                        }
                    }
                    .onEnded { _ in
                        points.append(.zero)
                    }
            )
        }
    }
}
