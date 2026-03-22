import SwiftUI

struct QuizView: View {
    let topic: Topic
    @ObservedObject var apiService: APIService

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var selectedAnswer: Answer? = nil
    @State private var submitResponse: SubmitResponse? = nil
    @State private var isLoading = true
    @State private var showSummary = false
    @State private var correctCount = 0
    @State private var startTime = Date()

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                loadingView
            } else if showSummary {
                SummaryView(
                    correct: correctCount,
                    total: questions.count,
                    topic: topic.name
                )
            } else if let question = currentQuestion {
                // Top progress bar — fixed
                progressBar
                    .padding()
                    .background(Color.white)

                if submitResponse == nil {
                    // Question + answers screen
                    questionScreen(question: question)
                } else {
                    // Result + explanation screen
                    resultScreen
                }
            }
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "f5f5f5").ignoresSafeArea())
        .onAppear(perform: loadQuestions)
    }

    // MARK: — Loading
    var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(2)
            Text("AI generating questions...")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("~10 seconds first time")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Progress Bar
    var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if let q = currentQuestion {
                    DifficultyBadge(difficulty: q.difficulty)
                }
            }
            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(questions.count)
            )
            .tint(Color(hex: "1a237e"))
        }
    }

    // MARK: — Question Screen
    func questionScreen(question: Question) -> some View {
        VStack(spacing: 0) {
            // Question text — scrollable
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(question.text)
                        .font(.body)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)

                    Text("Select an answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    VStack(spacing: 10) {
                        ForEach(question.answers) { answer in
                            Button(action: {
                                selectAnswer(answer, question: question)
                            }) {
                                HStack {
                                    Text(answer.text)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    selectedAnswer?.id == answer.id ?
                                    Color(hex: "e8eaf6") : Color.white
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedAnswer?.id == answer.id ?
                                            Color(hex: "1a237e") : Color.gray.opacity(0.2),
                                            lineWidth: 2
                                        )
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    // MARK: — Result Screen
    var resultScreen: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let response = submitResponse {
                        // Result banner
                        HStack(spacing: 12) {
                            Image(systemName: response.is_correct ?
                                  "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(response.is_correct ? .green : .red)
                            VStack(alignment: .leading) {
                                Text(response.is_correct ? "Correct! 🎉" : "Incorrect")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(response.is_correct ? .green : .red)
                                Text("Accuracy: \(Int(response.accuracy_rate))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            response.is_correct ?
                            Color.green.opacity(0.1) : Color.red.opacity(0.1)
                        )
                        .cornerRadius(12)

                        // Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Explanation")
                                .font(.headline)
                            Text(response.explanation)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                        // Difficulty indicator
                        HStack {
                            Image(systemName: "speedometer")
                            Text("Current difficulty: \(response.current_difficulty.capitalized)")
                            Spacer()
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
            }

            // Next button — always visible at bottom
            Button(action: nextQuestion) {
                Text(currentIndex + 1 < questions.count ?
                     "Next Question →" : "See Results 🏆")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "1a237e"))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: — Functions
    func loadQuestions() {
        isLoading = true
        apiService.getQuestions(topicId: topic.id) { questions in
            self.questions = questions
            self.isLoading = false
            self.startTime = Date()
        }
    }

    func selectAnswer(_ answer: Answer, question: Question) {
        guard submitResponse == nil else { return }
        selectedAnswer = answer
        let timeTaken = Int(Date().timeIntervalSince(startTime))

        apiService.submitAnswer(
            questionId: question.id,
            topicId: topic.id,
            answerId: answer.id,
            timeTaken: timeTaken
        ) { response in
            self.submitResponse = response
            if response.is_correct { self.correctCount += 1 }
        }
    }

    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            submitResponse = nil
            startTime = Date()
        } else {
            showSummary = true
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: String

    var color: Color {
        switch difficulty {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .gray
        }
    }

    var body: some View {
        Text(difficulty.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct SummaryView: View {
    let correct: Int
    let total: Int
    let topic: String
    @Environment(\.dismiss) var dismiss

    var accuracy: Int { total > 0 ? (correct * 100) / total : 0 }

    var emoji: String {
        switch accuracy {
        case 80...100: return "🏆"
        case 60...79: return "👍"
        case 40...59: return "💪"
        default: return "📚"
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text(emoji)
                .font(.system(size: 80))

            VStack(spacing: 8) {
                Text("Session Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                Text(topic)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 40) {
                StatBox(title: "Correct", value: "\(correct)", color: .green)
                StatBox(title: "Wrong", value: "\(total - correct)", color: .red)
                StatBox(title: "Accuracy", value: "\(accuracy)%", color: .blue)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8)
            .padding(.horizontal)

            VStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Study Another Topic")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "1a237e"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                Button(action: { dismiss() }) {
                    Text("Go Home")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color(hex: "1a237e"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "1a237e"), lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(hex: "f5f5f5").ignoresSafeArea())
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        QuizView(
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
}
