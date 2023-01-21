/*
 Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-sprinter

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/// YAML Content
public enum YAMLContent: Hashable, Equatable {
    case `nil`
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([YAMLContent])
    case dictionary([String: YAMLContent])

    public var value: AnyHashable? {
        switch self {
        case .nil:
            return nil
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .array(let array):
            return array.map { $0.value }
        case .dictionary(let dictionary):
            let value: [String: AnyHashable?] = dictionary.mapValues { $0.value }
            return value
        }
    }

    public var string: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }

    public var int: Int? {
        switch self {
        case .int(let value):
            return value
        default:
            return nil
        }
    }

    public var double: Double? {
        switch self {
        case .double(let value):
            return value
        default:
            return nil
        }
    }

    public var bool: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }

    public var array: [YAMLContent]? {
        switch self {
        case .array(let value):
            return value
        default:
            return nil
        }
    }

    public var dictionary: [String: YAMLContent]? {
        switch self {
        case .dictionary(let value):
            return value
        default:
            return nil
        }
    }

    public init(with value: AnyHashable) throws {
        if let string = value as? String {
            self = .string(string)
            return
        }
        if let bool = value as? Bool {
            self = .bool(bool)
            return
        }
        if let int = value as? Int {
            self = .int(int)
            return
        }
        if let double = value as? Double {
            self = .double(double)
            return
        }
        if let array = value as? [AnyHashable] {
            let list = try array.compactMap { try YAMLContent(with: $0) }
            self = .array(list)
            return
        }
        if let dictionary = value as? [String: AnyHashable] {
            let dict = try dictionary.mapValues { try YAMLContent(with: $0) }
            self = .dictionary(dict)
            return
        }
        if let _ = value as? NSNull {
            self = .nil
            return
        }
        throw HashableContextCodableError.unableToEncodeHashableContext
    }
}

extension YAMLContent: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else {
            self = .nil
            return
        }
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self = .int(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .double(value)
            return
        }
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        if let value = try? container.decode([String: YAMLContent].self) {
            self = .dictionary(value)
            return
        }
        if let value = try? container.decode([YAMLContent].self) {
            self = .array(value)
            return
        }
        throw HashableContextCodableError.unableToDecodeHashableContext
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nil:
            try container.encodeNil()
        case .bool(let bool):
            try container.encode(bool)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .string(let string):
            try container.encode(string)
        case .array(let array):
            try container.encode(array)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        }
    }
}

private enum HashableContextCodableError: Error {
    case unableToDecodeHashableContext
    case unableToEncodeHashableContext
}
