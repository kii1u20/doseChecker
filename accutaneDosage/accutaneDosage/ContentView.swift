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
            .onChange(of: value) { newValue in
                withAnimation(.easeInOut(duration: duration)) {
                    // Animate through intermediate values
                    animatingValue = newValue
                }
            }
            .contentTransition(.numericText())
    }
}

struct ContentView: View {
    @AppStorage("currentDose") private var currentDoseString: String = ""
    @AppStorage("totalDose") private var totalDose: Double = 0
    @AppStorage("weight") private var weight: String = ""
    @AppStorage("showWeightPrompt") private var showWeightPrompt: Bool = true
    @State private var showingResetAlert = false
    
    // Calculate maximum dose based on weight (120mg/kg)
    private var maxDose: Double {
        guard let weightKg = Double(weight) else { return 0 }
        return weightKg * 120
    }
    
    // Calculate remaining dose
    private var remainingDose: Double {
        return max(maxDose - totalDose, 0)
    }
    
    private var totalDosePerKg: Double {
        return totalDose / (Double(weight) ?? 0)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if showWeightPrompt {
                    weightInputView
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    mainTrackerView
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding()
            .navigationTitle("Dose Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingResetAlert = true
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                    }
                    .alert("Confirm Reset", isPresented: $showingResetAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Reset", role: .destructive) {
                            withAnimation {
                                totalDose = 0
                                currentDoseString = ""
                            }
                        }
                    } message: {
                        Text("Are you sure you want to reset the total dose to zero?")
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showWeightPrompt)
        }
    }
    
    private var weightInputView: some View {
        VStack(spacing: 20) {
            Text("Please enter your weight to begin")
                .font(.headline)
            
            TextField("Weight in kg", text: $weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Button("Continue") {
                if !weight.isEmpty {
                    withAnimation {
                        showWeightPrompt = false
                    }
                }
            }
            .disabled(weight.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var mainTrackerView: some View {
        VStack(spacing: 20) {
            // Total dose display
            VStack {
                Text("Total Dose Taken")
                    .font(.headline)
                FlipCounter(value: totalDose, unitOfMeasurement: "mg", duration: 0.5)
                Text("Total Dose per kg")
                    .bold()
                FlipCounter(value: totalDosePerKg, unitOfMeasurement: "mg/kg", duration: 0.5)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.5))
            .cornerRadius(10)
            
            // Maximum and remaining dose info
            VStack(spacing: 8) {
                Text("Maximum Dose: \(maxDose, specifier: "%.1f") mg")
                Text("Remaining: \(remainingDose, specifier: "%.1f") mg")
            }
            .font(.subheadline)
            
            // New dose input
            TextField("Enter dose (mg)", text: $currentDoseString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            // Add dose button
            Button("Dose Taken") {
                if let dose = Double(currentDoseString) {
                    withAnimation {
                        totalDose += dose
                        currentDoseString = ""
                    }
                }
            }
            .disabled(currentDoseString.isEmpty)
            .buttonStyle(.borderedProminent)
            
            // Warning message if close to max dose
            if remainingDose <= 20 && remainingDose > 0 {
                Text("Warning: Approaching maximum dose")
                    .foregroundColor(.orange)
                    .transition(.opacity)
            } else if remainingDose <= 0 {
                Text("Maximum dose reached!")
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            Spacer()
            
            // Weight update button
            Button("Update Weight") {
                withAnimation {
                    showWeightPrompt = true
                }
            }
            .font(.footnote)
        }
    }
}

#Preview {
    ContentView()
}
