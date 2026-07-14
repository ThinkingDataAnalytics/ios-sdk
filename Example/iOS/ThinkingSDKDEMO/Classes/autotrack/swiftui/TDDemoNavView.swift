import SwiftUI

// MARK: - Root View (NavigationView 容器)

@available(iOS 13.0, *)
struct TDDemoNavRootView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("SwiftUI NavigationLink")
                    .font(.title)
                    .fontWeight(.bold)

                Text("验证 NavigationLink 跳转时\n#screen_name 的解析结果")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Divider()

                // 跳转到有 navigationTitle 的页面（应能正确获取 screen_name）
                NavigationLink(destination: TDDemoNavSecondView()) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("→ SecondView（有 navigationTitle）")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(10)
                }

                // 跳转到没有 navigationTitle 的页面（会 fallback 到 UIHostingController）
                NavigationLink(destination: TDDemoNavNoTitleView()) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("→ NoTitleView（无 navigationTitle）")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
                }

                Spacer()

                Text("观察 Xcode Console 中\nta_app_view 事件的 #screen_name 字段")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationBarTitle("TDDemoNavRootView", displayMode: .inline)
        }
    }
}

// MARK: - Second View（有 navigationTitle，期望 screen_name = "TDDemoNavSecondView"）

@available(iOS 13.0, *)
struct TDDemoNavSecondView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "2.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("TDDemoNavSecondView")
                .font(.title)

            Text("此页面加了 .navigationTitle\n期望 #screen_name = \"TDDemoNavSecondView\"")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            NavigationLink(destination: TDDemoNavThirdView()) {
                HStack {
                    Image(systemName: "3.circle.fill")
                        .foregroundColor(.purple)
                    Text("→ ThirdView（继续深入一层）")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.15))
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("TDDemoNavSecondView", displayMode: .inline)
    }
}

// MARK: - Third View（有 navigationTitle，期望 screen_name = "TDDemoNavThirdView"）

@available(iOS 13.0, *)
struct TDDemoNavThirdView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "3.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)

            Text("TDDemoNavThirdView")
                .font(.title)

            Text("第三层，验证深层 NavigationLink\n期望 #screen_name = \"TDDemoNavThirdView\"")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .navigationBarTitle("TDDemoNavThirdView", displayMode: .inline)
    }
}

// MARK: - No Title View（无 navigationTitle，screen_name = "TDDemoNavNoTitleView"）

@available(iOS 13.0, *)
struct TDDemoNavNoTitleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("TDDemoNavNoTitleView")
                .font(.title)

            Text("此页面没有设置 .navigationTitle\n#screen_name = \"TDDemoNavNoTitleView\"")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        // 故意不加 .navigationTitle，用于对比验证
    }
}
