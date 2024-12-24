import SwiftUI
import AVFoundation
import UIKit
import SwiftData

struct CountingView: View {
    let totalBeads = 11
    let loopedBeads: [Int]

    @State private var selectedIndex: Int?
    @State private var beadCounts: [Int]
    @State private var previousIndex: Int
    @State private var num_count: Int
    @State private var isAnimating: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var startTime: Date
    @State private var name: String
    
    @Binding var isPresented: Bool

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    var onDone: (Int, Date, TimeInterval, String) -> Void

    init(onDone: @escaping (Int, Date, TimeInterval, String) -> Void,
         isPresented: Binding<Bool>,
         inputName: String)
    {
        self.onDone = onDone
        self._isPresented = isPresented
        let beads = Array(0..<totalBeads)
        self.loopedBeads = beads + beads + beads
        self._selectedIndex = State(initialValue: totalBeads)
        self._beadCounts = State(initialValue: Array(repeating: 0, count: totalBeads))
        self._previousIndex = State(initialValue: totalBeads)
        self.num_count = 0
        self._startTime = State(initialValue: Date()) // 記錄開始時間
        self._name = State(initialValue: inputName) // 使用傳入的姓名
    }
    
    func circularDistance(from: Int, to: Int, total: Int) -> Int {
        let diff = abs(to - from) % total
        return min(diff, total - diff)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button("退出") {
                        showSaveAlert = true
                    }
                    .padding()
                    .foregroundColor(.red)
                    .alert(isPresented: $showSaveAlert) {
                        Alert(
                            title: Text("退出"),
                            message: Text("是否儲存這次的資料？"),
                            primaryButton: .default(Text("是")) {
                                let duration = Date().timeIntervalSince(startTime)
                                onDone(num_count, startTime, duration, name)
                                isPresented = false // 返回到主畫面
                            },
                            secondaryButton: .destructive(Text("否")) {
                                isPresented = false // 返回到主畫面，不存檔
                            }
                        )
                    }
                    Spacer()
                }

                Spacer(minLength: geometry.size.height * 0.2)
                
                Text("念佛者：\(name)")
                    .font(.headline)
                Text("目前選擇珠：Bead \(loopedBeads[previousIndex]) - 累計計數：\(num_count)")
                    .font(.headline)
                    .padding()

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<loopedBeads.count, id: \.self) { index in
                            let beadNumber = loopedBeads[index]
                            let currentIndex = selectedIndex ?? totalBeads
                            let distance = circularDistance(from: currentIndex, to: index, total: totalBeads)
                            let maxScale: CGFloat = 2.2
                            let minScale: CGFloat = 0.5
                            let scale = max(minScale, maxScale - CGFloat(distance) * 0.5)

                            HStack {
                                Spacer()
                                VStack(spacing: 5) {
                                    Image("bead")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 2)
                                        .scaleEffect(isAnimating && distance == 0 ? 1.1 : scale)
                                        .opacity(isAnimating && distance == 0 ? 0.9 : 1.0)
                                        .animation(.easeInOut(duration: 0.07), value: isAnimating)
                                        .rotation3DEffect(
                                            Angle(degrees: Double(distance) * 5),
                                            axis: (x: 1.0, y: 0.0, z: 0.0),
                                            perspective: 0.5
                                        )
                                }
                                Spacer()
                            }
                            .frame(height: 60)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .frame(height: 300)
                .scrollPosition(id: $selectedIndex, anchor: .center)
                .scrollTargetBehavior(.viewAligned)
                .onChange(of: selectedIndex) { newIndex in
                    handleSelectionChange(newIndex)
                }
            }
        }
        .navigationTitle("佛珠計數")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedIndex = totalBeads
            hapticGenerator.prepare()
        }
    }
    
    func adjustIndex(_ index: Int) -> Int {
        var correctedIndex = index
        if correctedIndex < totalBeads {
            correctedIndex += totalBeads
        } else if correctedIndex >= totalBeads * 2 {
            correctedIndex -= totalBeads
        }
        return correctedIndex
    }

    func handleSelectionChange(_ newIndex: Int?) {
        guard let newIndex = newIndex else { return }

        let correctedIndex = adjustIndex(newIndex)
        let difference = correctedIndex - previousIndex

        if difference == -1 || difference == totalBeads - 1 {
            let actualBead = loopedBeads[correctedIndex]

            withAnimation {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                withAnimation {
                    isAnimating = false
                }
            }

            AudioServicesPlaySystemSound(1104) // 系統音效 ID
            hapticGenerator.impactOccurred()

            beadCounts[actualBead] += 1
            num_count += 1
            previousIndex = correctedIndex
            selectedIndex = correctedIndex
        } else {
            selectedIndex = previousIndex
        }
    }
}
