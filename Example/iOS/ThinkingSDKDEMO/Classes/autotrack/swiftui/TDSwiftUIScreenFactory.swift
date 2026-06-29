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

    @objc static func swiftRootViewName() -> String {
        if #available(iOS 13.0, *) {
            return String(describing: TDDemoVastRendererView.self)
        }
        return "Unavailable"
    }
}
