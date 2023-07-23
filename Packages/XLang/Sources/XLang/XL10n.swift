import Foundation

struct UserDefaultsKey {
    static let selectedLang: String = {
        return (Bundle.main.bundleIdentifier ?? "") + "selectedLang"
    }()
}

public class XLang {
    public static let shared = XLang()
    
    private let userDefaults = UserDefaults.standard
    
    public var currentLang: Language
    
    private init() {
        let selected = userDefaults.string(forKey: UserDefaultsKey.selectedLang)
        let lang = selected ?? Bundle.main.preferredLocalizations.first ?? "en"
        currentLang = Language(rawValue: lang) ?? .en
    }
    
    /// 修改 App 语言
    public func setLang(_ lang: Language) {
        userDefaults.set(lang.rawValue, forKey: UserDefaultsKey.selectedLang)
        userDefaults.synchronize()
        currentLang = lang
        Bundle.resetCurrentBundle()
    }
}

extension Bundle {
    private static var _current: Bundle?
    
    public static var current: Bundle {
        if let curr = _current {
            return curr
        }
        
        let lang = XLang.shared.currentLang.rawValue
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        
        _current = bundle
        return bundle
    }
    
    static func resetCurrentBundle() {
        _current = nil
    }
}

