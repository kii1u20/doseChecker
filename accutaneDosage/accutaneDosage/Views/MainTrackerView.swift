import SwiftUI

struct MainTrackerView: View {
    @EnvironmentObject var doseTrackerVM: DoseTrackerViewModel
    @Environment(\.modelContext) private var modelContext
    @FocusState var isDoseFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Total dose display
            ScrollView {
                VStack {
                    Text("Total Dose Taken")
                        .font(.headline)
                    FlipCounter(value: doseTrackerVM.totalDose, unitOfMeasurement: "mg", duration: 0.5)
                    Text("Total Dose per kg")
                        .bold()
                    FlipCounter(value: doseTrackerVM.totalDosePerKg, unitOfMeasurement: "mg/kg", duration: 0.5)
                    
                    PillProgressView(
                        value: doseTrackerVM.totalDose,
                        maxValue: doseTrackerVM.maxDose,
                        color: doseTrackerVM.remainingDose <= 20 && doseTrackerVM.remainingDose > 0 ? .orange : doseTrackerVM.remainingDose <= 0 ? .red : .blue
                    )
                    .frame(height: 20)
                    .padding()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.5))
                .cornerRadius(10)
                
                // Maximum and remaining dose info
                VStack(spacing: 8) {
                    Text("Maximum Dose: \(doseTrackerVM.maxDose, specifier: "%.1f") mg")
                    Text("Remaining: \(doseTrackerVM.remainingDose, specifier: "%.1f") mg")
                }
                .font(.subheadline)
                
                //New dose input
                TextField(
                    "Enter dose (mg)",
                    text: doseTrackerVM.$currentDoseString
                )
                .padding(.vertical)
                .padding(.horizontal)
                .background(
                    Color(UIColor.systemGray6)
                )
                .clipShape(Capsule(style: .continuous))
                .keyboardType(.numberPad)
                .focused($isDoseFieldFocused)
                
                // Add dose button
                Button("Dose Taken") {
                    if let dose = Double(doseTrackerVM.currentDoseString) {
                        withAnimation {
                            doseTrackerVM.addDose(dose: dose, modelContext: modelContext)
                        }
                    }
                }
                .disabled(doseTrackerVM.currentDoseString.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .scrollDisabled(true) //Maybe leave enabled to dismiss keyboard by scrolling
            
            // Warning message if close to max dose
            if doseTrackerVM.remainingDose <= 20 && doseTrackerVM.remainingDose > 0 {
                Text("Warning: Approaching maximum dose")
                    .foregroundColor(.orange)
                    .transition(.opacity)
            } else if doseTrackerVM.remainingDose <= 0 {
                Text("Maximum dose reached!")
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            Spacer()
            
            NavigationLink {
                HistoryView(totalDose: doseTrackerVM.$totalDose)
            } label: {
                Label("View History", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            
            // Weight update button
            Button("Update Weight and Goal") {
                withAnimation {
                    doseTrackerVM.showWeightPrompt = true
                }
            }
            .font(.footnote)
        }
        .onTapGesture {
            isDoseFieldFocused = false
        }
    }
}
