import SwiftUI
import Dependencies

struct PremiumUpgradeSheet: View {
    @Dependency(\.premiumAccessManager) var premiumAccessManager
    @Dependency(\.themeManager) var themeManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var showSuccessModal = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemYellow).opacity(0.08).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    // Close button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .appCircularButtonStyle()
                        }
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.leading, 12)

                    // Top image
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.indigo, Color.purple]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 90, height: 90)
                        .mask(
                            Image(systemName: "book.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .frame(width: 90, height: 90)
                    
                    // Title & description
                    Text("Upgrade to Premium and keep your diary distraction-free!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    Text("Unlock the full Habit Diary experience with exclusive benefits:")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            Text("• ").font(.title3).fontWeight(.bold)
                            Text("No Ads: ")
                                .fontWeight(.semibold) + Text("Write your habit journal with zero interruptions.")
                        }
                        HStack(alignment: .top) {
                            Text("• ").font(.title3).fontWeight(.bold)
                            Text("Pure Focus: ")
                                .fontWeight(.semibold) + Text("A clean, immersive journaling experience every day.")
                        }
                    }
                    .font(.body)
                    .padding(.horizontal)

                    // Purchase button
                    if let product = premiumAccessManager.premiumProduct {
                        if premiumAccessManager.isPremiumUserPurchased {
                            Text("You are now Premium user!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                        } else {
                            Button(action: {
                                Task {
                                    isPurchasing = true
                                    let result = await premiumAccessManager.purchasePremium()
                                    switch result {
                                    case .success:
                                        showSuccessModal = true
                                    case .failure(let error):
                                        print("Purchase failed: \(error.localizedDescription)")
                                    }
                                    isPurchasing = false
                                }
                            }) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text("\(product.displayPrice) - Upgrade to Premium")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(themeManager.current.primaryColor)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 16))
                            }
                            .padding(.horizontal)
                            .disabled(isPurchasing)
                        }
                    } else {
                        ProgressView()
                    }
                    // Links
                    VStack(spacing: 16) {
                        Button("Restore Purchases") {
                            Task {
                                isPurchasing = true
                                await premiumAccessManager.restorePurchases()
                                isPurchasing = false
                            }
                        }
                        .foregroundStyle(themeManager.current.primaryColor)
                        
                        Button("Contact Support") {
                            if let url = URL(string: "https://apps-bay.github.io/Apps-Bay-Website/contact/") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundStyle(themeManager.current.primaryColor)
                        
                        Button("Privacy Policy") {
                            if let url = URL(string: "https://apps-bay.github.io/Apps-Bay-Website/privacy/") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundStyle(themeManager.current.primaryColor)
                    }
                    .font(.body)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showSuccessModal) {
            PremiumCelebrationView()
        }
        .task {
            await premiumAccessManager.loadPremiumProduct()
        }
    }
}

struct ConfettiDot: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let size: CGFloat
}

struct PremiumCelebrationView: View {
    var onContinue: (() -> Void)? = nil
    @State private var animate = false
    @Environment(\.dismiss) var dismiss
    
    private let confetti: [ConfettiDot] = (0..<20).map { _ in
        ConfettiDot(
            x: CGFloat.random(in: 40...340),
            y: CGFloat.random(in: 40...600),
            color: [Color.yellow, Color.orange, Color.green, Color.blue, Color.pink, Color.purple].randomElement()!,
            size: CGFloat.random(in: 8...16)
        )
    }

    var body: some View {
        ZStack {
            Color.white.opacity(0.4).ignoresSafeArea()

            // Confetti
            ForEach(confetti) { dot in
                Circle()
                    .fill(dot.color)
                    .frame(width: dot.size, height: dot.size)
                    .position(x: dot.x, y: animate ? dot.y : dot.y - 80)
                    .opacity(0.7)
                    .animation(.easeOut(duration: 1.2), value: animate)
            }

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 120, height: 120)
                        .blur(radius: 8)
                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.yellow)
                        .shadow(color: .yellow, radius: 12)
                }
                Text("Congratulations!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text("💎 Thanks for being a Premium member!")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                        Text("Ad-free experience")
                    }
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text("Thank you for supporting Habit Diary!")
                    }
                }
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(radius: 4)
                }
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.yellow.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
            )
            .shadow(radius: 24)
            .padding(.horizontal, 24)
            .onAppear { animate = true }
        }
    }
}

#Preview {
    PremiumUpgradeSheet()
} 
