//
//  ServiceDetailView.swift
//  debtMe
//
//  Created by Misael Landero on 16/06/24.
//

import SwiftUI

struct ServiceDetailView: View {
    @ObservedObject var service : Services
    var showsNavigationChrome = true
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    @State var showEdit = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        #if os(macOS)
        VStack(spacing: 8) {
            if showsNavigationChrome {
                List {
                    serviceSummarySection
                }
                .listStyle(.plain)
                .frame(minHeight: 110, maxHeight: 190)
            } else {
                ServiceInspectorCard(
                    service: service,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
            }

            AmountUpdateList(service: service)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(showsNavigationChrome ? service.wrappedName : "")
        .toolbar { if showsNavigationChrome { editToolbarItem } }
        .sheet(isPresented: $showEdit, content: {
            ServicesForm(edition:true, service: service)
        })
        #else
        List{
            serviceSummarySection
            AmountUpdateList(service: service)
        }
        .navigationTitle(service.wrappedName)
        .toolbar{
            editToolbarItem
        }
        .sheet(isPresented: $showEdit, content: {
            ServicesForm(edition:true, service: service)
        })
        #endif
    }

    private var serviceSummarySection: some View {
        Section{
            ServiceRow(BgColor: service.wrappedColor, ServiceName: service.wrappedName, Amount: service.amount.toCurrencyString(), frequency: service.frecuencyString, limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted), image: service.image, expense: service.expense)
            Text(service.wrappedDes)
                .multilineTextAlignment(.leading)
        }
        .listRowBackground(service.wrappedColor)
    }

    private var editToolbarItem: some ToolbarContent {
        ToolbarItem(placement:.primaryAction){
            Button(action:{
                showEdit.toggle()
            }){
                Label("Edit", systemImage: AppIcons.edit)
                    .appToolbarLabel()
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#if os(macOS)
private struct ServiceInspectorCard: View {
    @ObservedObject var service: Services
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ServiceRow(
                BgColor: service.wrappedColor,
                ServiceName: service.wrappedName,
                Amount: service.amount.toCurrencyString(),
                frequency: service.frecuencyString,
                limitDate: service.frequencyDate.formatted(date: .abbreviated, time: .omitted),
                image: service.image,
                expense: service.expense,
                useAdaptiveText: true
            )

            if !service.wrappedDes.isEmpty {
                Text(service.wrappedDes)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            HStack(spacing: 10) {
                Button {
                    onEdit?()
                } label: {
                    Label("Edit", systemImage: AppIcons.edit)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)

                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 1.0, green: 0.12, blue: 0.08))
            }
        }
        .padding(14)
        .background(service.wrappedColor.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(service.wrappedColor.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 12)
    }
}
#endif

 
