import SwiftUI

struct WeightInputView: View {
    @EnvironmentObject var doseTrackerVM: DoseTrackerViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Please enter your weight")
                .font(.headline)
            
            TextField("Weight in kg", text: doseTrackerVM.$weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Text("Please enter your goal mg/kg")
                .font(.headline)
            
            TextField("Goal in mg/kg", text: doseTrackerVM.$goalMgKg)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Button("Continue") {
                if !doseTrackerVM.weight.isEmpty {
                    withAnimation {
                        doseTrackerVM.showWeightPrompt = false
                    }
                }
            }
            .disabled(doseTrackerVM.weight.isEmpty || doseTrackerVM.goalMgKg.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
}
