//
//  KeychainAccess.swift
//  Electoral College Fantasy League
//
//  Created by Chase Smith on 10/16/16.
//  Copyright © 2016 ls -applications. All rights reserved.
//

import Foundation

struct KeychainAccess {
	
	enum KeychainError: Error {
		case noPassword
		case unexpectedPasswordData
		case unhandledError(status: OSStatus)
	}
	
	static func savePassword(_ password: String, forAccount account: String) throws {
		let encodedPassword = password.data(using: .utf8)!
		let status: OSStatus
		if try readPassword(forAccount: account) == nil {
			// Create new account
			var query = buildQuery(forAccount: account)
			query[kSecValueData as String] = encodedPassword as AnyObject?
			status = SecItemAdd(query as CFDictionary, nil)
		} else {
			// Update password
			var updateAttributes = [String: AnyObject]()
			updateAttributes[kSecValueData as String] = encodedPassword as AnyObject?
			let query = buildQuery(forAccount: account)
			status = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
		}
		if status != noErr {
			throw KeychainError.unhandledError(status: status)
		}
	}
	
	static func readPassword(forAccount account: String) throws -> String? {
		var query = buildQuery(forAccount: account)
		query[kSecMatchLimit as String] = kSecMatchLimitOne
		query[kSecReturnAttributes as String] = kCFBooleanTrue
		query[kSecReturnData as String] = kCFBooleanTrue
		var queryResults: AnyObject?
		let status = withUnsafeMutablePointer(to: &queryResults) {
			SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
		}
		if status == errSecItemNotFound {
			return nil
		} else if status != noErr {
			throw KeychainError.unhandledError(status: status)
		}
		guard let passwordDict = queryResults as? [String: AnyObject], let passwordData = passwordDict[kSecValueData as String] as? Data, let password = String(data: passwordData, encoding: .utf8)
			else {
				throw KeychainError.unexpectedPasswordData
		}
		return password
	}
	
	static func buildQuery(forAccount account: String) -> [String: AnyObject] {
		var query = [String: AnyObject]()
		query[kSecClass as String] = kSecClassGenericPassword
		query[kSecAttrAccount as String] = account as AnyObject?
		return query
	}
}
