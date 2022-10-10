//
//  Spinner.swift
//  
//
//  Created by Thomas Roovers on 07/10/2022.
//

import Foundation
import SwiftUI

public struct Spinner: View {

    let rotationTime: Double = 0.75
    let animationTime: Double = 1.75 // Sum of all animation times
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)

    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEnd: CGFloat = 0.03

    @State var rotationDegree = initialDegree
    
    public let lineWidth: CGFloat
    
    public init(lineWidth: CGFloat = 4) {
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: spinnerStart, to: spinnerEnd)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color.Branding.primary)
                    .rotationEffect(rotationDegree)
            }
        }
        .onAppear() {
            self.animateSpinner()
            
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { (mainTimer) in
                self.animateSpinner()
            }
        }
    }

    func animateSpinner(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }

    func animateSpinner() {
        animateSpinner(with: rotationTime) {
            self.spinnerEnd = 1.0
        }

        animateSpinner(with: (rotationTime * 2) - 0.05) {
            self.rotationDegree += fullRotation
        }

        animateSpinner(with: rotationTime * 2) {
            self.spinnerEnd = 0.03
        }
    }
}
