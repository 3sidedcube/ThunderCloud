import UIKit

extension UIWindow {

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard Bundle.main.infoDictionary?["TSCStormLoginDisabled"] == nil else {
            return
        }
        guard motion == .motionShake else {
            return
        }

        #if DEBUG
        LocalisationController.shared.toggleEditing()
        #else
        // In release builds we only allow toggling localisation editing
        // when the build was provisioned for testing (i.e. has an
        // embedded.mobileprovision in the main bundle).
        if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
            LocalisationController.shared.toggleEditing()
        }
        #endif
    }
}
