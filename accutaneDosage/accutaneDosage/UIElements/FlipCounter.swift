import SwiftUI

struct FlipCounter: View {
    let value: Double
    let duration: Double
    let unitOfMeasurement: String
    @State private var animatingValue: Double
    
    init(value: Double, unitOfMeasurement:String, duration: Double = 1.0) {
        self.value = value
        self.duration = duration
        self.unitOfMeasurement = unitOfMeasurement
        self._animatingValue = State(initialValue: value)
    }
    
    var body: some View {
        Text("\(animatingValue, specifier: "%.1f") \(unitOfMeasurement)")
            .font(.largeTitle)
            .bold()
            .onChange(of: value) { oldValue, newValue in
                withAnimation(.easeInOut(duration: duration)) {
                    // Animate through intermediate values
                    animatingValue = newValue
                }
            }
            .contentTransition(.numericText())
    }
}
