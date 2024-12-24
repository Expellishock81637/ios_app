import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedDate: Date = Date()
    @State private var isCountingPresented = false
    @State private var isAskingName = false
    @State private var inputName: String = ""
    @Environment(\.modelContext) private var modelContext
    @State private var allRecords: [BeadCountRecord] = [] // Track all records

    // 為 navigationDestination 使用的識別資料結構
    struct MonthlyChartNavigation: Hashable {
        var monthDate: Date
    }

    var body: some View {
        NavigationStack {
            VStack {
                CalendarView(selectedDate: $selectedDate)
                    .frame(height: 300)
                    .padding()

                Text("選取日期：\(formattedDate(selectedDate))")
                    .font(.headline)
                    .padding()

                let dailyRecords = recordsForSelectedDate
                if dailyRecords.isEmpty {
                    Text("目前沒有紀錄")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(dailyRecords, id: \.self) { record in
                            NavigationLink(destination: EditRecordView(record: record)) {
                                HStack {
                                    Text("念佛數：\(record.count), \(record.name)")
                                    Spacer()
                                    Text(formattedTime(record.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteRecord(record: record)
                                } label: {
                                    Label("刪除", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                // 新增「查看圖表」按鈕，傳入當前選取日期所在月份
                NavigationLink(value: MonthlyChartNavigation(monthDate: selectedDate)) {
                    Text("查看當月圖表")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: {
                    inputName = ""
                    isAskingName = true
                }) {
                    Text("新增紀錄")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .alert("請輸入念佛者的姓名或法號", isPresented: $isAskingName) {
                    TextField("姓名/法號", text: $inputName)
                    Button("確定") {
                        if !inputName.isEmpty {
                            isCountingPresented = true
                        }
                    }
                    Button("取消", role: .cancel) {}
                }

            }
            .navigationTitle("紀錄清單")
            .sheet(isPresented: $isCountingPresented) {
                CountingView(
                    onDone: { finalCount, startTime, duration, name in
                        addNewRecord(count: finalCount, startTime: startTime, duration: duration, name: name)
                        isCountingPresented = false
                    },
                    isPresented: $isCountingPresented,
                    inputName: inputName
                )
            }
            .onAppear {
                loadAllRecords()
            }
            // 定義 navigationDestination：當NavigationLink(value:) 帶入 MonthlyChartNavigation 時，顯示 MonthlyChartView
            .navigationDestination(for: MonthlyChartNavigation.self) { navValue in
                MonthlyChartView(monthDate: navValue.monthDate, allRecords: allRecords)
            }
        }
    }

    private var recordsForSelectedDate: [BeadCountRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return allRecords.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }

    private func addNewRecord(count: Int, startTime: Date, duration: TimeInterval, name: String) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let dateForRecord = startOfDay.addingTimeInterval(Date().timeIntervalSince(startOfDay))
        let newRecord = BeadCountRecord(date: dateForRecord, startTime: startTime, duration: duration, count: count, name: name)
        modelContext.insert(newRecord)
        do {
            try modelContext.save()
            print("Record saved successfully: \(newRecord)")
            loadAllRecords()
        } catch {
            print("Save error: \(error)")
        }
    }

    private func deleteRecord(record: BeadCountRecord) {
        modelContext.delete(record)
        do {
            try modelContext.save()
            print("Record deleted successfully: \(record)")
            loadAllRecords()
        } catch {
            print("Delete error: \(error)")
        }
    }

    private func loadAllRecords() {
        let descriptor = FetchDescriptor<BeadCountRecord>() // 預設提取所有資料
        do {
            allRecords = try modelContext.fetch(descriptor)
            print("All Records Reloaded: \(allRecords)")
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
