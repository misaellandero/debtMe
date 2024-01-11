//
//  PaymentsListTransactionsView.swift
//  debtMe
//
//  Created by Misael Landero on 12/02/23.
//

import SwiftUI
import AVFoundation

struct PaymentsTransactionsList: View {
    
    
    //Model View de Coredata
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var transaction : Transaction
    @State var showAddPayment = false
    
    //To hide view
    @Environment(\.presentationMode) var presentationMode
    
    @State var paymentTotal : Double = 0.0
    
    @State var counter = 0
    @State var counterMoneylose = 0
    @State  var bombSoundEffect: AVAudioPlayer?
    
    @State var alert = false
    
    @State var totalBalance = 0.0
    
    @State var showMore = false
    
    var body: some View {
    
       ZStack{
          
           
             ScrollView(.vertical){
               
                 Section{ 
                     
                     Text(transaction.wrappedNotes)
                         .multilineTextAlignment(.leading)
                     
                 }
                 .padding(.horizontal)
                 
                if transaction.settled {
                    if totalBalance != 0  {
                        Button(action: {
                            setTranssationSeatled(settled: false)
                        }){
                            ButtonLabelReset()
                        }
                    }
                } else {
                    Button(action: {
                        setTranssationSeatled(settled: true)
                        checkForMoneyLose()
                    }){
                        ButtonLabelPayAll()
                    }
                }
                
                if transaction.paymentsArray.count < 1 {
                    EmptyPaymentView(empty: true) 
                    Spacer()
                } else {
                    LazyVStack(content: {
                        
                        ForEach(transaction.paymentsArray, id : \.id){ payment in
                            PaymentRow(payment: payment, updateTotal: getTotals)
                           
                        }
                        
                        EmptyPaymentView()
                    })
                }
         
                
            }
            .onAppear(perform: getTotals)
            .onDisappear(perform: {
                //update here to avoid view to reload before time
                //this would update contact balance
                self.transaction.contact?.sync.toggle()
                try? self.moc.save()
            })
            .padding(.top, 0.03)
            TotalsView(amount: transaction.amount, current: $paymentTotal)
            ConfettiView(counter: $counter)
            ConfettiMoneyView(counter:$counterMoneylose)
        }
        #if os(iOS)
        .background(.ultraThinMaterial)
        .toolbar {
            ToolbarItem(placement:.principal){
                Text(transaction.wrappedDes)
            }
            ToolbarItem(placement:.principal){
                Text("\(Image(systemName: "folder")) Summary")
            }
        }
        #elseif os(macOS)
        .padding()
        .toolbar {
            ToolbarItem(placement:.automatic){
                Text(transaction.wrappedDes) 
            }
        }
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic ){
                Button(action:{
                    showAddPayment.toggle()
                }){
                    Label("Add", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .disabled(transaction.settled)
            }
        }
        .sheet(isPresented: $showAddPayment.onChange(modalUpdate)){
            PaymentNewForm(transaction: transaction)
        }
      
       
    }
    
    
    func modalUpdate(_ tag: Bool){
        getTotals()
        checkforConffeti()
    }
    
    func getTotals(){
        var total = 0.0
        for payment in transaction.paymentsArray {
            total += payment.amount
        }
        paymentTotal = total
        
        totalBalance = transaction.totalBalance
    }
    
    func checkforConffeti(){
        if transaction.settled && transaction.totalBalance == 0 {
            counter += 1
            playAudio()
        }
        
    }
    
    func checkForMoneyLose(){
        counterMoneylose += 1
        playAudio()
    }
    
    
    func setTranssationSeatled(settled: Bool) {
        transaction.settled = settled
        checkforConffeti()
        try? self.moc.save()
         
    }
    
    func playAudio(){
       let path = Bundle.main.path(forResource: "ConfettiPopSoundEffectLong.m4a", ofType:nil)!
       let url = URL(fileURLWithPath: path)

       do {
           bombSoundEffect = try AVAudioPlayer(contentsOf: url)
           bombSoundEffect?.play()
       } catch {
           // couldn't load file :(
       }
   }
   
}
 
