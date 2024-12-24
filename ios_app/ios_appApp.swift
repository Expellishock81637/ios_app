import SwiftUI
import SwiftData

@main
struct ios_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: BeadCountRecord.self) // 注册数据模型
        }
    }
}
