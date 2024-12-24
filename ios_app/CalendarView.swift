import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var isCountingViewPresented: Bool = false // 控制是否顯示 CountingView

    private var calendar = Calendar.current
    private var currentMonthDates: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else {
            return []
        }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        VStack {
            // 年份和月份導航
            HStack {
                // 上一年按鈕
                Button(action: {
                    changeYear(by: -1)
                }) {
                    Image(systemName: "chevron.up")
                        .font(.title2)
                        .padding(.leading)
                }

                Spacer()

                // 上一月按鈕
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.leading)
                }

                Spacer()

                // 月份年份顯示
                Text(currentMonthYearString(for: selectedDate))
                    .font(.headline)

                Spacer()

                // 下一月按鈕
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding(.trailing)
                }

                Spacer()

                // 下一年按鈕
                Button(action: {
                    changeYear(by: 1)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .padding(.trailing)
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                ForEach(currentMonthDates, id: \.self) { date in
                    Button(action: {
                        selectedDate = date // 僅選擇日期，暫時不進入計數畫面
                    }) {
                        Text("\(calendar.component(.day, from: date))")
                            .frame(width: 30, height: 30)
                            .foregroundColor(isSameDay(date, selectedDate) ? .white : .primary)
                            .background(isSameDay(date, selectedDate) ? Color.blue : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
        }
        // 已移除 .sheet 修飾符
    }

    private var weekdayHeaders: [String] {
        let symbols = calendar.shortWeekdaySymbols
        return symbols
    }

    private func currentMonthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter.string(from: date)
    }

    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    // 切換月份的方法
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }

    // 切換年份的方法
    private func changeYear(by value: Int) {
        if let newDate = calendar.date(byAdding: .year, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
