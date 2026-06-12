//
//  ButtonLabelAdd.swift
//  debtMe
//
//  Created by Misael Landero on 22/04/23.
//

import SwiftUI

struct AppActionButtonStyle: ButtonStyle {
    var tint: Color
    var foreground: Color = .white
    var cornerRadius: CGFloat = 10
    var expandsHorizontally = true
    var font: Font = .headline

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(.titleAndIcon)
            .font(font)
            .foregroundStyle(foreground)
            .frame(maxWidth: expandsHorizontally ? .infinity : nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                tint.opacity(configuration.isPressed ? 0.78 : 1),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == AppActionButtonStyle {
    static var appAdd: AppActionButtonStyle {
        AppActionButtonStyle(tint: .accentColor)
    }

    static var appContinue: AppActionButtonStyle {
        AppActionButtonStyle(tint: .accentColor)
    }

    static var appPayAll: AppActionButtonStyle {
        AppActionButtonStyle(tint: .green)
    }

    static var appReset: AppActionButtonStyle {
        AppActionButtonStyle(tint: .orange)
    }

    static var appShowSettled: AppActionButtonStyle {
        AppActionButtonStyle(tint: .gray, expandsHorizontally: false, font: .body)
    }

    static func appAction(
        tint: Color,
        foreground: Color = .white,
        expandsHorizontally: Bool = true
    ) -> AppActionButtonStyle {
        AppActionButtonStyle(tint: tint, foreground: foreground, expandsHorizontally: expandsHorizontally)
    }
}

struct ButtonLabelAdd: View {
    var label : String = "Add"
    var systemImage: String = "plus.circle.fill"
    var foreground : Color = .white
    var body: some View {
        HStack{
            Spacer()
            LabelSFRounder(label: label, systemImage: systemImage, foreground: foreground)
                .font(.headline)
                .padding()
            Spacer()
        }
        .background(Color.accentColor )
        .cornerRadius(10)
        .padding()
        
    }
}

struct ButtonLabelAdd_Previews: PreviewProvider {
    static var previews: some View {
        ButtonLabelAdd(label: "Add", systemImage:  "plus.circle.fill", foreground: .white)
    }
}
