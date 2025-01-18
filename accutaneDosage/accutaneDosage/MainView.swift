import SwiftUI

struct MainView: View {
    
    @State private var showingResetAlert = false
    
    @EnvironmentObject var doseTrackerVM: DoseTrackerViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                if doseTrackerVM.showWeightPrompt {
                    WeightInputView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    MainTrackerView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding()
            .navigationTitle("Dose Tracker")
            .ignoresSafeArea(.keyboard) // Add this modifier
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
                                doseTrackerVM.reset()
                            }
                        }
                    } message: {
                        Text("Are you sure you want to reset the total dose to zero?")
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: doseTrackerVM.showWeightPrompt)
        }
        .task {
            doseTrackerVM.loadHistory()
        }
    }
    
    
    
}

#Preview {
    MainView()
        .environmentObject(DoseTrackerViewModel())
}
