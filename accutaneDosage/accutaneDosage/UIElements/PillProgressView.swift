import SwiftUI

struct PillProgressView: View {
    let value: Double
    let maxValue: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background pill
                Capsule()
                    .foregroundColor(Color(.systemGray5))
                    .frame(height: 20)
                
                // Filled progress pill
                Capsule()
                    .frame(width: min(CGFloat(value)/CGFloat(maxValue) * geometry.size.width, geometry.size.width), height: 20)
                    .foregroundColor(color)
                    .animation(.easeInOut, value: value)
            }
        }
    }
}
