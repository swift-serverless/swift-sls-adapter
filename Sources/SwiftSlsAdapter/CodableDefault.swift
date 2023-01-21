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

public protocol CodableDefaultSource: Equatable {
    associatedtype Value: Codable & Equatable
    static var defaultValue: Value { get }
}

/// CodableDefault
///
/// Set a Codable Default value
public enum CodableDefault {}

extension CodableDefault: Equatable {
    @propertyWrapper
    public struct Wrapper<Source: CodableDefaultSource>: Equatable {
        public init(wrappedValue: Source.Value = Source.defaultValue) {
            self.wrappedValue = wrappedValue
        }

        typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue
    }
}

extension CodableDefault.Wrapper: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(
        _ type: CodableDefault.Wrapper<T>.Type,
        forKey key: Key
    ) throws -> CodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

public extension CodableDefault {
    typealias Source = CodableDefaultSource
    typealias List = Codable & ExpressibleByArrayLiteral & Equatable
    typealias Map = Codable & ExpressibleByDictionaryLiteral & Equatable

    enum Sources {
        public enum True: Source, Equatable {
            public static var defaultValue: Bool { true }
        }

        public enum False: Source, Equatable {
            public static var defaultValue: Bool { false }
        }

        public enum EmptyString: Source, Equatable {
            public static var defaultValue: String { "" }
        }

        public enum EmptyList<T: List>: Source where T: Equatable {
            public static var defaultValue: T { [] }
        }

        public enum EmptyMap<T: Map>: Source where T: Equatable {
            public static var defaultValue: T { [:] }
        }

        public enum FirstCase<T: Codable>: Source where T: CaseIterable, T: Equatable {
            public static var defaultValue: T { T.allCases.first! }
        }
    }
}

public extension CodableDefault {
    /// Set Codable default to `true`
    typealias True = Wrapper<Sources.True>
    /// Set Codable default to `false`
    typealias False = Wrapper<Sources.False>
    /// Set Codable default to `""`
    typealias EmptyString = Wrapper<Sources.EmptyString>
    /// Set Codable default to `[]`
    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>> where T: Equatable
    /// Set Codable default to `[:]`
    typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>> where T: Equatable
    /// Set Codable default to the `enum` first case
    typealias FirstCase<T: Codable> = Wrapper<Sources.FirstCase<T>> where T: CaseIterable, T: Equatable
}
