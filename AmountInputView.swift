//
//  AmountInputView.swift
//  Xpense Logger
//
//  Created by Spike Nunn on 19/09/2025.
//


import SwiftUI

struct AmountInputView: View {
    @Binding var amount: String
    @Binding var isPresented: Bool
    let onSave: (String) -> Void
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Amount to Claim")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(alignment: .leading) {
                    Text("Amount (£)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: saveAmount) {
                    Text("Save Receipt")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            amount.isEmpty ? Color.gray : Color.green
                        )
                        .cornerRadius(12)
                }
                .disabled(amount.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Add Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Invalid Amount", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveAmount() {
        // Validate the amount
        guard !amount.isEmpty else {
            alertMessage = "Please enter an amount"
            showingAlert = true
            return
        }
        
        // Check if it's a valid number
        guard let _ = Double(amount), Double(amount) ?? 0 > 0 else {
            alertMessage = "Please enter a valid amount greater than 0"
            showingAlert = true
            return
        }
        
        onSave(amount)
        isPresented = false
    }
}

#Preview {
    AmountInputView(
        amount: .constant("10.50"),
        isPresented: .constant(true),
        onSave: { _ in }
    )
}