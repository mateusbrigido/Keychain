import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class Keychain {
    
    func addOrUpdateItem(with options: Options) throws {
        if let _ = getPassword(options: options) {
            try updateItem(with: options)
        } else {
            try addItem(with: options)
        }
    }
    
    private func addItem(with options: Options) throws {
        var query = options.query()
        options.attributes().forEach { query[$0.key] = $0.value }
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private func updateItem(with options: Options) throws {
        let status = SecItemUpdate(options.query() as CFDictionary, options.attributes() as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    func getPassword(options: Options) -> (account: String, password: String)? {
        var query = options.query()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess,
            let matchingItem = item as? [String: Any],
            let data = matchingItem[kSecValueData as String] as? Data,
            let password = String(data: data, encoding: .utf8),
            let account = matchingItem[kSecAttrAccount as String] as? String {
            
            return (account, password)
        }
        
        return nil
    }
    
    func deletePassword(with options: Options) throws {
        let status = SecItemDelete(options.query() as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
}

//MARK: -Options
extension Keychain {
    struct Options {
        var itemClass: ItemClass
        var account: String?
        var service: String?
        var server: String?
        
        var data: Data?
        var label: String?
        var accessibility: Accessibility? = .afterFirstUnlock
     
        fileprivate func query() -> [String: Any] {
            var query = [String: Any]()
            
            switch itemClass {
            case .genericPassword:
                query[kSecClass as String] = kSecClassGenericPassword
                query[kSecAttrAccount as String] = account
                query[kSecAttrService as String] = (service ?? Bundle.main.bundleIdentifier)
            case .internetPassword:
                query[kSecClass as String] = kSecClassInternetPassword
                query[kSecAttrAccount as String] = account
                query[kSecAttrServer as String] = server
            }
            
            return query
        }
        
        fileprivate func attributes() -> [String: Any] {
            var attributes = [String: Any]()
            if let label = self.label { attributes[kSecAttrLabel as String] = label }
            if let data = self.data { attributes[kSecValueData as String] = data }
            
            return attributes
        }
    }
    
}

//MARK: -ItemClass
extension Keychain {
    enum ItemClass {
        case genericPassword
        case internetPassword
    }
}

//MARK: -Accessibility
extension Keychain {
    enum Accessibility {
        case whenUnlocked
        case afterFirstUnlock
        case whenPasscodeSetThisDeviceOnly
        case whenUnlockedThisDeviceOnly
        case afterFirstUnlockThisDeviceOnly
    }
}
