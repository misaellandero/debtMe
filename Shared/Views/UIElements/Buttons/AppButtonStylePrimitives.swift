//
//  AppButtonStylePrimitives.swift
//  debtMe
//
//  Shared button rendering primitives. Do not apply these directly from views;
//  use one of the named app button styles in this folder.
//

import SwiftUI

struct AppActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var tint: Color
    var foreground: Color = .white
    var cornerRadius: CGFloat = 18
    var expandsHorizontally = true
    var font: Font = .headline

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let effectiveTint = isEnabled ? tint : tint.opacity(0.45)

        configuration.label
            .labelStyle(.titleAndIcon)
            .font(font)
            .foregroundStyle(foreground)
            .tint(foreground)
            .frame(maxWidth: expandsHorizontally ? .infinity : nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .appButtonGlassFill(tint: effectiveTint, cornerRadius: cornerRadius)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

struct AppToolbarCircleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var tint: Color
    var foreground: Color
    var usesFilledBackground = true
#if os(macOS)
    var size: CGFloat = 34
#else
    var size: CGFloat = 44
#endif

    private var iconFont: Font {
#if os(macOS)
        .body.weight(.semibold)
#else
        .title3.weight(.semibold)
#endif
    }

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let effectiveTint = isEnabled ? tint : tint.opacity(0.45)

        configuration.label
            .labelStyle(.iconOnly)
            .font(iconFont)
            .foregroundStyle(foreground)
            .tint(foreground)
            .frame(width: size, height: size)
            .appToolbarGlassFill(
                tint: effectiveTint,
                usesFilledBackground: usesFilledBackground
            )
            .contentShape(Circle())
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

struct AppToolbarIconLabel: View {
    var systemImage: String
    var accessibilityLabel: LocalizedStringKey
    var tint: Color = AppTheme.actionTint

    private var size: CGFloat {
#if os(macOS)
        34
#else
        44
#endif
    }

    private var iconFont: Font {
#if os(macOS)
        .body.weight(.semibold)
#else
        .title3.weight(.semibold)
#endif
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(iconFont)
            .foregroundStyle(.white)
            .tint(.white)
            .frame(width: size, height: size)
            .appProminentGlassFill(tint: tint, shape: .circle)
            .contentShape(Circle())
            .accessibilityLabel(accessibilityLabel)
    }
}

enum AppGlassShape {
    case circle
    case capsule
    case roundedRectangle(CGFloat)
}

extension View {
    @ViewBuilder
    func appProminentGlassFill(tint: Color = AppTheme.actionTint, shape: AppGlassShape = .capsule) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            switch shape {
            case .circle:
                self
                    .glassEffect(.regular.tint(tint).interactive(), in: .circle)
                    .background(tint, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                    .contentShape(Circle())
            case .capsule:
                self
                    .glassEffect(.regular.tint(tint).interactive(), in: .capsule)
                    .background(tint, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                    .contentShape(Capsule())
            case .roundedRectangle(let radius):
                self
                    .glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: radius))
                    .background(tint, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            }
        } else {
            switch shape {
            case .circle:
                self
                    .background(tint, in: Circle())
                    .contentShape(Circle())
            case .capsule:
                self
                    .background(tint, in: Capsule())
                    .contentShape(Capsule())
            case .roundedRectangle(let radius):
                self
                    .background(tint, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func appButtonGlassFill(tint: Color, cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            self
                .glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
                .background(tint, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.32), lineWidth: 1)
                )
        } else {
            self
                .background(tint, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    @ViewBuilder
    func appToolbarGlassFill(tint: Color, usesFilledBackground: Bool) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            if usesFilledBackground {
                self
                    .glassEffect(.regular.tint(tint).interactive(), in: .circle)
                    .background(tint, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )
            } else {
                self
                    .glassEffect(.regular.tint(tint.opacity(0.18)).interactive(), in: .circle)
            }
        } else {
            if usesFilledBackground {
                self
                    .background(tint, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.45), lineWidth: 1)
                    }
                    .shadow(color: tint.opacity(0.22), radius: 8, x: 0, y: 4)
            } else {
                self
                    .background(tint.opacity(0.12), in: Circle())
            }
        }
    }
}
