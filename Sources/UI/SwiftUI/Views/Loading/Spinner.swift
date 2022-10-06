//
//  Spinner.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import SwiftUI

struct Spinner: View {
    
    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var rotationDegreeS1 = initialDegree
    
    let rotationTime: Double = 0.75
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)

    var body: some View {
        ZStack {
            SpinnerCircle(start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, color: Color.theme.primary)
        }
        .frame(width: 200, height: 200)
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { (mainTimer) in
                self.animateSpinner(with: rotationTime) {
                    self.spinnerEndS1 = 1.0
                }
            }
        }
    }

    // MARK: Animation methods
    func animateSpinner(with timeInterval: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: rotationTime)) {
                completion()
            }
        }
    }
}

extension Spinner {
    struct SpinnerCircle: View {
        var start: CGFloat
        var end: CGFloat
        var rotation: Angle
        var color: Color
        
        var body: some View {
            Circle()
                .trim(from: start, to: end)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .fill(color)
                .rotationEffect(rotation)
        }
    }
}
