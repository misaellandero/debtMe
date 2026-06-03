//
//  HomeDateNavigator.swift
//  debtMe
//
//  Created by Codex on 02/06/26.
//

import SwiftUI

struct HomeDateNavigator: View {
    @Binding var viewMode: ServicesViewMode
    @Binding var calendarPeriod: CalendarPeriod
    @Binding var fromToday: Bool
    let dateRangeLabel: String
    let isShowingToday: Bool
    let namespace: Namespace.ID
    let onPrevious: () -> Void
    let onToday: () -> Void
    let onNext: () -> Void

    var body: some View {
       
        #if os(macOS)
        HStack(spacing: 8) {
            HomeViewModeButton(viewMode: $viewMode, namespace: namespace)
            Picker("Period", selection: $calendarPeriod) {
                ForEach(CalendarPeriod.allCases, id: \.self) { option in
                    Text(LocalizedStringKey(option.rawValue))
                        .tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            if calendarPeriod != .day && calendarPeriod != .untilNextIncome {
                #if os(macOS)
                Toggle("From today", isOn: $fromToday)
                    .toggleStyle(.checkbox)
                #else
                Toggle("From today", isOn: $fromToday)
                    .labelsHidden()
                #endif
            }

            if calendarPeriod != .untilNextIncome {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                }

                Button(action: onToday) {
                    Text("Today")
                }
                .disabled(isShowingToday)

                Text(dateRangeLabel)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding(12)
        .glassEffect()
        #else
        HStack(spacing: 8) {
            if calendarPeriod != .untilNextIncome {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(GlassProminentButtonStyle())

                Button(action: onToday) {
                    Text("Today")
                }
                .disabled(isShowingToday)

                Text(dateRangeLabel)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(GlassProminentButtonStyle())
            } else {
                Text(dateRangeLabel)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(12)
        .glassEffect(in: .rect(cornerRadius: 16.0))
        #endif
    }
}

struct HomeDateNavigatorTopControls: View {
    @Binding var viewMode: ServicesViewMode
    @Binding var calendarPeriod: CalendarPeriod
    @Binding var fromToday: Bool
    let namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 8) {
            HomeViewModeButton(viewMode: $viewMode, namespace: namespace)

            Picker("Period", selection: $calendarPeriod) {
                ForEach(CalendarPeriod.allCases, id: \.self) { option in
                    Text(LocalizedStringKey(option.rawValue))
                        .tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            if calendarPeriod != .day && calendarPeriod != .untilNextIncome {
                Toggle("From today", isOn: $fromToday)
                    .toggleStyle(.button)
            }
        }
    }
}

private struct HomeViewModeButton: View {
    @Binding var viewMode: ServicesViewMode
    let namespace: Namespace.ID

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.32)) {
                viewMode = (viewMode == .calendar) ? .list : .calendar
            }
        } label: {
            ZStack {
                Label("Calendar", systemImage: "calendar")
                    .appToolbarLabel()
                    .hidden()
                Label("List", systemImage: "list.bullet")
                    .appToolbarLabel()
                    .hidden()
                Label(
                    viewMode == .calendar ? "List" : "Calendar",
                    systemImage: viewMode == .calendar ? "list.bullet" : "calendar"
                )
                .appToolbarLabel()
            }
        }
        #if os(iOS)
        .labelStyle(.iconOnly)
        #endif
        .buttonStyle(GlassProminentButtonStyle())
        .glassEffectID("home-calendar", in: namespace)
    }
}
