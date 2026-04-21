import SwiftUI

struct TheoryCardView: View {
    let topic: Topic
    @ObservedObject var apiService: APIService
    @Environment(\.dismiss) var dismiss

    @State private var cards: [TheoryCard] = []
    @State private var currentIndex = 0
    @State private var isLoading = true
    @State private var offset = CGSize.zero
    @State private var masteredCount = 0
    @State private var reviewCount = 0
    @State private var showComplete = false

    var currentCard: TheoryCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a237e"), Color(hex: "283593")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if showComplete {
                completeView
            } else if let card = currentCard {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("\(currentIndex + 1) / \(cards.count)")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        Spacer()
                        HStack(spacing: 12) {
                            Label("\(masteredCount)", systemImage: "checkmark")
                                .foregroundColor(.green)
                            Label("\(reviewCount)", systemImage: "arrow.counterclockwise")
                                .foregroundColor(.orange)
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)

                    // Progress bar
                    ProgressView(
                        value: Double(currentIndex),
                        total: Double(cards.count)
                    )
                    .tint(.white)
                    .padding(.horizontal)

                    // Swipe hints
                    HStack {
                        Label("Review", systemImage: "arrow.left")
                            .foregroundColor(.orange.opacity(0.8))
                        Spacer()
                        Label("Got it!", systemImage: "arrow.right")
                            .foregroundColor(.green.opacity(0.8))
                    }
                    .font(.caption)
                    .padding(.horizontal)

                    Spacer()

                    // Card with swipe
                    ZStack {
                        if offset.width > 50 {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.3))
                                .overlay(
                                    Text("✅ Got It!")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                )
                                .padding()
                        } else if offset.width < -50 {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.orange.opacity(0.3))
                                .overlay(
                                    Text("🔄 Review")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                )
                                .padding()
                        }

                        cardContent(card: card)
                            .offset(offset)
                            .rotationEffect(.degrees(Double(offset.width / 20)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        handleSwipe(gesture)
                                    }
                            )
                            .animation(.spring(), value: offset)
                    }

                    Spacer()

                    Text("Swipe right = Got it • Swipe left = Review")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadCards)
    }

    // MARK: — Card Content
    func cardContent(card: TheoryCard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Category badge
                HStack {
                    Text(categoryEmoji(card.category))
                    Text(card.category.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                Divider()

                // Concept
                Text(card.concept)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal)

                // Explanation
                Text(card.explanation)
                    .font(.body)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.horizontal)

                // Formula
                if let formula = card.formula, !formula.isEmpty {
                    Text(formula)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "1a237e"))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Divider()

                // Example
                VStack(alignment: .leading, spacing: 4) {
                    Text("📌 Example")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text(card.example)
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding(.horizontal)

                // Memory trick
                VStack(alignment: .leading, spacing: 4) {
                    Text("🧠 Memory Trick")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text(card.memory_trick)
                        .font(.body)
                        .foregroundColor(Color(hex: "1a237e"))
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10)
            .padding(.horizontal)
        }
    }

    // MARK: — Loading
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
                .tint(.white)
            Text("Generating theory cards...")
                .foregroundColor(.white)
                .font(.headline)
            Text("AI is creating personalized cards")
                .foregroundColor(.white.opacity(0.7))
                .font(.caption)
        }
    }

    // MARK: — Complete
    var completeView: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("🎉")
                .font(.system(size: 80))
            Text("Topic Complete!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 40) {
                VStack {
                    Text("\(masteredCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Mastered")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                VStack {
                    Text("\(reviewCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("To Review")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(16)

            VStack(spacing: 12) {
                Button(action: {
                    currentIndex = 0
                    masteredCount = 0
                    reviewCount = 0
                    showComplete = false
                }) {
                    Text("Review Again")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: { dismiss() }) {
                    Text("Back to Topics")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color(hex: "1a237e"))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    // MARK: — Functions
    func loadCards() {
        isLoading = true
        apiService.getTheoryCards(topicId: topic.id) { response in
            DispatchQueue.main.async {
                if let response = response {
                    self.cards = response.cards
                }
                self.isLoading = false
            }
        }
    }

    func handleSwipe(_ gesture: DragGesture.Value) {
        if gesture.translation.width > 100 {
            masteredCount += 1
            nextCard()
        } else if gesture.translation.width < -100 {
            reviewCount += 1
            if let card = currentCard {
                cards.append(card)
            }
            nextCard()
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }

    func nextCard() {
        withAnimation(.spring()) {
            offset = CGSize(
                width: offset.width > 0 ? 1000 : -1000,
                height: 0
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            offset = .zero
            if currentIndex >= cards.count {
                showComplete = true
            }
        }
    }

    func categoryEmoji(_ category: String) -> String {
        switch category {
        case "formula": return "📐"
        case "definition": return "📖"
        case "concept": return "💡"
        case "comparison": return "⚖️"
        case "trick": return "🧠"
        default: return "📌"
        }
    }
}

#Preview {
    TheoryCardView(
        topic: Topic(
            id: 1,
            name: "Cost Management",
            cma_part: 1,
            description: nil,
            icon: "💰",
            weightage: 15
        ),
        apiService: APIService()
    )
}
