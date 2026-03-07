import SwiftUI

struct LaunchView: View {
    @State private var cardOffset: CGFloat = 40
    @State private var cardOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var isFinished = false

    var body: some View {
        if isFinished {
            HomeView()
        } else {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Glow
                Circle()
                    .fill(Color(hex: "#e94560").opacity(0.12))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(y: -60)

                VStack(spacing: 0) {
                    Spacer()

                    // Stacked cards animation
                    ZStack {
                        // Card 3
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#0f3460"))
                            .frame(width: 180, height: 120)
                            .rotationEffect(.degrees(-14))
                            .offset(x: -12, y: cardOffset + 12)
                            .opacity(cardOpacity)

                        // Card 2
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#e94560").opacity(0.85))
                            .frame(width: 180, height: 120)
                            .rotationEffect(.degrees(-5))
                            .offset(x: -4, y: cardOffset * 0.5 + 4)
                            .opacity(cardOpacity)

                        // Card 1 (front)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .frame(width: 180, height: 120)
                            .overlay(
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(hex: "#e94560"))
                            )
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            .offset(y: cardOpacity == 1 ? 0 : cardOffset)
                            .opacity(cardOpacity)
                    }
                    .frame(height: 180)

                    Spacer().frame(height: 48)

                    // Logo text
                    Text("flipd")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    Spacer().frame(height: 12)

                    // Tagline
                    Text("learn faster. remember longer.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(taglineOpacity)

                    Spacer()
                }
            }
            .onAppear { animate() }
        }
    }

    private func animate() {
        // Cards fly in
        withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
            cardOffset = 0
            cardOpacity = 1
        }

        // Logo pops in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.5)) {
            logoScale = 1
            logoOpacity = 1
        }

        // Tagline fades in
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            taglineOpacity = 1
        }

        // Transition to HomeView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFinished = true
            }
        }
    }
}

#Preview {
    LaunchView()
}
