import SwiftUI
import Charts

struct MonthlyChartView: View {
    var monthDate: Date
    var allRecords: [BeadCountRecord]

    var body: some View {
        VStack {
            Text("當月念佛統計")
                .font(.title2)
                .padding()

            // 使用 Bar Chart 顯示每日念佛總數
            Chart {
                ForEach(monthlyData) { dayData in
                    BarMark(
                        x: .value("日期", dayData.date, unit: .day),
                        y: .value("總念佛數", dayData.totalCount)
                    )
                    .annotation(position: .top) {
                        Text("\(dayData.totalCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 300)
            .padding()

            Spacer()
        }
        .navigationTitle("\(formattedMonthTitle(monthDate))的統計")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 計算該月份每一天的念佛總數
    private var monthlyData: [DailyData] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        // 篩選該月的記錄
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: 0), to: startOfMonth)!
        let thisMonthRecords = allRecords.filter { $0.date >= startOfMonth && $0.date < endOfMonth }

        // 將記錄依日期分組，加總次數
        var dailySum: [Date: Int] = [:]
        for record in thisMonthRecords {
            let dayStart = calendar.startOfDay(for: record.date)
            dailySum[dayStart, default: 0] += record.count
        }

        // 創建每日資料結構，如當天沒紀錄則總數為0
        return range.compactMap { day -> DailyData? in
            if let date = calendar.date(byAdding: .day, value: day-1, to: startOfMonth) {
                let totalCount = dailySum[date] ?? 0
                return DailyData(date: date, totalCount: totalCount)
            }
            return nil
        }
    }

    private func formattedMonthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }

    struct DailyData: Identifiable {
        var id: Date { date }
        var date: Date
        var totalCount: Int
    }
}
