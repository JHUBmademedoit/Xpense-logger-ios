import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Receipt.timestamp, ascending: false)],
        animation: .default)
    private var receipts: FetchedResults<Receipt>
    
    @State private var showingCamera = false
    @State private var showingAmountInput = false
    @State private var currentAmount = ""
    @State private var currentImageData: Data?
    
    var totalAmount: Double {
        receipts.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Total Amount Display
                VStack {
                    Text("Total to Claim")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("£\(totalAmount, specifier: "%.2f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Add Receipt Button
                Button(action: {
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Add Receipt")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding()
                
                // Receipts List
                if receipts.isEmpty {
                    VStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No receipts yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Tap 'Add Receipt' to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(receipts) { receipt in
                            ReceiptRowView(receipt: receipt)
                        }
                        .onDelete(perform: deleteReceipts)
                    }
                }
            }
            .navigationTitle("Xpense Logger")
            .sheet(isPresented: $showingCamera) {
                CameraView(isPresented: $showingCamera) { imageData in
                    currentImageData = imageData
                    showingAmountInput = true
                }
            }
            .sheet(isPresented: $showingAmountInput) {
                AmountInputView(
                    amount: $currentAmount,
                    isPresented: $showingAmountInput,
                    onSave: { amount in
                        if let imageData = currentImageData,
                           let amountValue = Double(amount) {
                            addReceipt(imageData: imageData, amount: amountValue)
                        }
                        currentImageData = nil
                        currentAmount = ""
                    }
                )
            }
        }
    }
    
    private func addReceipt(imageData: Data, amount: Double) {
        withAnimation {
            let newReceipt = Receipt(context: viewContext)
            newReceipt.id = UUID()
            newReceipt.timestamp = Date()
            newReceipt.imageData = imageData
            newReceipt.amount = amount
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving receipt: \(error)")
            }
        }
    }
    
    private func deleteReceipts(offsets: IndexSet) {
        withAnimation {
            offsets.map { receipts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting receipt: \(error)")
            }
        }
    }
}

struct ReceiptRowView: View {
    let receipt: Receipt
    
    var body: some View {
        HStack {
            // Receipt Image
            if let imageData = receipt.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("£\(receipt.amount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let timestamp = receipt.timestamp {
                    Text(timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
