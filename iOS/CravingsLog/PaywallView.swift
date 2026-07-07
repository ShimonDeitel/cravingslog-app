import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(AppTheme.rule)
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.accent)

            Text("Cravings Log Pro")
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.ink)

            Text("Pattern charts by time-of-day and trigger tags")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.inkFaded)
                .padding(.horizontal, 24)

            if let product = purchases.product {
                Button {
                    Task { await purchases.purchase() }
                } label: {
                    Text("Unlock for \(product.displayPrice)/month")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("paywallPurchaseButton")
                .padding(.horizontal, 24)
            } else {
                ProgressView().padding()
            }

            Button("Restore Purchases") {
                Task { await purchases.restore() }
            }
            .font(.footnote)
            .foregroundStyle(AppTheme.inkFaded)
            .accessibilityIdentifier("paywallRestoreButton")

            Button("Not now") { dismiss() }
                .font(.footnote)
                .foregroundStyle(AppTheme.inkFaded)
                .padding(.top, 4)
                .accessibilityIdentifier("paywallDismissButton")

            Spacer()
        }
        .padding(.top, 4)
        .background(AppTheme.backdrop.ignoresSafeArea())
    }
}
