import SwiftUI

struct TranslationEmptyView: View {
    let state: TranslationContentState
    let onGenerate: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        Group {
            switch state {
            case .missingConfiguration:
                ContentUnavailableView {
                    Label("尚未配置翻译", systemImage: "key")
                } description: {
                    Text("请先在设置中配置 DeepSeek API Key。")
                } actions: {
                    Button("前往设置", action: onOpenSettings)
                }
            case .empty:
                ContentUnavailableView {
                    Label("尚未生成译文", systemImage: "character.book.closed")
                } description: {
                    Text("SkillDock 会将当前 SKILL.md 发送给 DeepSeek 生成中文译文。")
                } actions: {
                    Button("生成译文", action: onGenerate)
                        .buttonStyle(.borderedProminent)
                }
            case .generating:
                ContentUnavailableView {
                    ProgressView()
                    Text("正在生成译文")
                } description: {
                    Text("完成前可以继续查看原文。")
                }
            case .failed(let message):
                ContentUnavailableView {
                    Label("生成失败", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("重试", action: onGenerate)
                }
            case .original, .available:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
