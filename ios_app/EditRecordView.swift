import SwiftUI
import SwiftData

struct EditRecordView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss // 用於關閉編輯視圖
    @State var record: BeadCountRecord
    @State private var editedName: String
    @State private var editedCount: String // 使用字串以便直接編輯次數

    init(record: BeadCountRecord) {
        self.record = record
        _editedName = State(initialValue: record.name)
        _editedCount = State(initialValue: String(record.count)) // 初始化為字串
    }

    var body: some View {
        Form {
            Section(header: Text("編輯資訊")) {
                TextField("姓名/法號", text: $editedName)
                TextField("念佛次數", text: $editedCount)
                    .keyboardType(.numberPad) // 限制為數字鍵盤
            }

            Section(header: Text("紀錄日期與時間")) {
                HStack {
                    Text("日期：")
                        .bold()
                    Spacer()
                    Text(formattedDate(record.date))
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("開始時間：")
                        .bold()
                    Spacer()
                    Text(formattedTime(record.startTime))
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("時長：")
                        .bold()
                    Spacer()
                    Text("\(formattedDuration(record.duration))")
                        .foregroundColor(.gray)
                }
            }

            Section {
                Button("儲存變更") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button("刪除紀錄") {
                    deleteRecord()
                }
                .foregroundColor(.red)
                .padding()
            }
        }
        .navigationTitle("編輯紀錄")
    }

    private func saveChanges() {
        guard let count = Int(editedCount), count >= 0 else {
            print("Invalid count value")
            return
        }

        record.name = editedName
        record.count = count
        do {
            try modelContext.save()
            dismiss() // 儲存後關閉編輯視圖
        } catch {
            print("Save Error: \(error)")
        }
    }

    private func deleteRecord() {
        modelContext.delete(record)
        do {
            try modelContext.save()
            dismiss() // 刪除後關閉編輯視圖
        } catch {
            print("Delete Error: \(error)")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return "\(hours)小時 \(minutes)分鐘 \(seconds)秒"
    }
}
