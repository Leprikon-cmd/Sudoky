//
//  LocalizedBundle.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 16.05.2025.
//
import Foundation

private var bundleKey: UInt8 = 0

class LocalizedBundle {
    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else { return }

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension Bundle {
    static var localized: Bundle {
        objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle ?? .main
    }
}

func loc(_ key: String) -> String {
    NSLocalizedString(key, bundle: .localized, comment: "")
}
