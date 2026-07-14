import SwiftUI
import UIKit

@objc(TDSwiftUIScreenFactory)
class TDSwiftUIScreenFactory: NSObject {
    @objc static func makeVastRendererHostingController() -> UIViewController {
        if #available(iOS 13.0, *) {
            let hostingController = UIHostingController(rootView: TDDemoVastRendererView())
            hostingController.title = "SwiftUI VastRenderer"
            return hostingController
        }

        let fallback = UIViewController()
        fallback.view.backgroundColor = .white
        fallback.title = "SwiftUI Unavailable"
        return fallback
    }

    /// NavigationLink 多层跳转的 screen_name 验证 VC。
    /// 包含 Root / Second / Third 三层页面，均设置了 .navigationTitle；
    /// 另有一个 NoTitle 页面故意不设 .navigationTitle 作对比。
    @objc static func makeNavLinkDemoHostingController() -> UIViewController {
        if #available(iOS 13.0, *) {
            let hostingController = UIHostingController(rootView: TDDemoNavRootView())
            hostingController.title = "TDDemoNavRootView"
            return hostingController
        }

        let fallback = UIViewController()
        fallback.view.backgroundColor = .white
        fallback.title = "SwiftUI Unavailable"
        return fallback
    }

    @objc static func swiftRootViewName() -> String {
        if #available(iOS 13.0, *) {
            return String(describing: TDDemoVastRendererView.self)
        }
        return "Unavailable"
    }
}
