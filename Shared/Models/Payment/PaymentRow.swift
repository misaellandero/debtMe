//
//  PaymentRow.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import SwiftUI
import CoreImage

struct PaymentRow: View {
    
    @ObservedObject var payment : Payment
    @State var showingAlert = false
    //Model View de Coredate
    @Environment(\.managedObjectContext) var moc
    
    let updateTotal: () -> Void
    
    @State var showEditPayment = false
    
    var body: some View {
            VStack{
                Spacer()
                Group{
                    VStack{
                        Text("Payment")
                            .font(.largeTitle)
                        HStack{
                            Button(action: {
                                showEditPayment.toggle()
                            }){
                                Image(systemName:"square.and.pencil" )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                            Button(action: {
                                showingAlert.toggle()
                            }){
                                Image(systemName:"trash.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        HStack{
                            ForEach(0..<10){_ in
                                Text("*")
                            }
                        }
                        .font(.body)
                        HStack{
                            Text(payment.creationDateFormated)
                        }
                        .font(.caption)
                        
                        HStack{
                            ForEach(0..<10){_ in
                                Text("*")
                            }
                        }
                        .font(.body)
                    }
                    if payment.wrappedNotes != "No notes provided" {
                        HStack{
                            Text(payment.wrappedNotes)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    HStack{
                        Text("Amount")
                        VStack{
                            Divider()
                                .foregroundColor(.secondary)
                        }
                        Text(payment.amount.toCurrencyString())
                        
                    }
                    
                }
                .padding()
                Spacer()
                ImageView(photoData: payment.image, imagename: payment.wrappedNotes)
                    .frame(height: 100)
                    .padding()
            }
            .alert(isPresented: $showingAlert){
                Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure?\n You won't be able to retrieve this information later."),
                    primaryButton: .destructive(Text("Delete")) {
                        delete()
                    },
                    secondaryButton: .cancel()
                )
            }
            .background(TicketViewBackground())
            .frame(maxWidth:500)
            .sheet(isPresented: $showEditPayment.onChange(modalUpdate)) {
                PaymentNewForm(edition:true, payment:payment)
            }
           
    }
    
    
    func modalUpdate(_ tag: Bool){
        updateTotal()
    }
    
    func delete(){
        self.moc.delete(payment) 
        try? self.moc.save()
        updateTotal()
    }
    
    func generateBarcode(from string: String) -> Image? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                #if os(iOS)
                let context = CIContext()
                let cgImage = context.createCGImage(output, from: output.extent)
                let uiImage = UIImage(cgImage: cgImage!)
                return Image(uiImage: uiImage)
                #elseif os(macOS)
                let cgImage = CIContext().createCGImage(output, from: output.extent)
                return Image(nsImage: NSImage(cgImage: cgImage!, size: NSSize(width: 500, height: 100)))
                #endif
            }
        }

        return nil
    }
    
}

 
