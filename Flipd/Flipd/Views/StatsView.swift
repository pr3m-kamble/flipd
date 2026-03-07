import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: ProgressViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats grid
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
                        StatCard(title: "Total Cards",    value: "\(viewModel.stats.totalCards)",   icon: "rectangle.stack",   color: .blue)
                        StatCard(title: "Mastered",       value: "\(viewModel.stats.masteredCards)", icon: "checkmark.seal",   color: .green)
                        StatCard(title: "Accuracy",       value: String(format: "%.0f%%", viewModel.stats.averageAccuracy), icon: "target", color: .orange)
                        StatCard(title: "Day Streak",     value: "\(viewModel.stats.streakDays)🔥",  icon: "flame",            color: .red)
                    }
                    .padding(.horizontal)

                    // Mastery breakdown
                    MasteryBreakdown(stats: viewModel.stats)
                        .padding(.horizontal)

                    // Recent sessions
                    if !viewModel.sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Sessions")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.recentSessions()) { session in
                                SessionRow(session: session)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Progress 📈")
            .onAppear { viewModel.reload() }
        }
    }
}

// MARK: - Stat Card
private struct StatCard: View {
    let title: String; let value: String; let icon: String; let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Spacer()
            Text(value).font(.title.bold())
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Mastery Breakdown
private struct MasteryBreakdown: View {
    let stats: ProgressStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mastery Breakdown").font(.headline)

            MasteryBar(label: "Mastered",  count: stats.masteredCards,  total: stats.totalCards, color: .green)
            MasteryBar(label: "Learning",  count: stats.learningCards,  total: stats.totalCards, color: .orange)
            MasteryBar(label: "Needs Work",count: stats.needsWorkCards, total: stats.totalCards, color: .red)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

private struct MasteryBar: View {
    let label: String; let count: Int; let total: Int; let color: Color

    var fraction: CGFloat {
        total > 0 ? CGFloat(count) / CGFloat(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                Text("\(count)").font(.subheadline).foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemFill)).frame(height: 8)
                    Capsule().fill(color).frame(width: geo.size.width * fraction, height: 8)
                        .animation(.spring(), value: fraction)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Session Row
private struct SessionRow: View {
    let session: StudySession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startedAt, style: .date).font(.subheadline.bold())
                Text("\(session.totalCards) cards · \(session.correctCount) correct")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text(String(format: "%.0f%%", session.accuracy))
                .font(.headline)
                .foregroundColor(session.accuracy >= 70 ? .green : .orange)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
