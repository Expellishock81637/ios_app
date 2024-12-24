import SwiftData
import Foundation

@Model
final class BeadCountRecord {
    var date: Date         // 日期
    var startTime: Date    // 开始时间
    var duration: TimeInterval // 念佛时长（秒）
    var count: Int         // 念佛次数
    var name: String       // 念佛者姓名/法号

    init(date: Date, startTime: Date, duration: TimeInterval, count: Int, name: String) {
        self.date = date
        self.startTime = startTime
        self.duration = duration
        self.count = count
        self.name = name
    }
}
