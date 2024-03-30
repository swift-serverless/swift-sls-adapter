/*
 Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-serverless

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

public typealias ARN = String

// MARK: - ServerlessConfig

/// ServerlessConfig configuration
public struct ServerlessConfig: Codable, Equatable {
    /// Initialise a ServerlessConfig configuration
    ///
    /// Reference: https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml
    ///
    /// - Parameters:
    ///   - service: Service Name
    ///   - frameworkVersion: Framework Version
    ///   - configValidationMode: Configuration validation: 'error' (fatal error), 'warn' (logged to the output) or 'off' (default: warn)
    ///   - useDotenv: Load environment variables from .env files (default: false)
    ///   - provider: Cloud Provider
    ///   - package: Package
    ///   - custom: Custom YAML content
    ///   - layers: Layers
    ///   - functions: Functions
    ///   - resources: YAML Resources
    public init(
        service: String,
        frameworkVersion: String = "3",
        configValidationMode: ServerlessConfig.ValidationMode = .warn,
        useDotenv: Bool = false,
        provider: Provider,
        package: Package?,
        custom: YAMLContent?,
        layers: [String: Layer]?,
        functions: [String: Function]?,
        resources: YAMLContent?
    ) {
        self.service = service
        self.frameworkVersion = frameworkVersion
        self.configValidationMode = configValidationMode
        self.useDotenv = useDotenv
        self.provider = provider
        self.package = package
        self.custom = custom
        self.layers = layers
        self.functions = functions
        self.resources = resources
    }

    /// Service name
    public let service: String

    /// Framework version constraint (semver constraint): '3', '^2.33'
    public let frameworkVersion: String

    /// Configuration validation: 'error' (fatal error), 'warn' (logged to the output) or 'off' (default: warn)
    /// See https://www.serverless.com/framework/docs/configuration-validation
    public let configValidationMode: ValidationMode

    /// Load environment variables from .env files (default: false)
    /// See https://www.serverless.com/framework/docs/environment-variables
    @CodableDefault.False public var useDotenv: Bool

    /// Cloud Provider
    public let provider: Provider

    /// Optional deployment packaging configuration
    public let package: Package?

    /// Custom YAML content
    public let custom: YAMLContent?

    /// Layers
    public let layers: [String: Layer]?

    /// Functions
    public let functions: [String: Function]?

    /// YAML Resources
    public let resources: YAMLContent?
}

extension ServerlessConfig {
    // MARK: - ServerlessConfigPackage

    /// ValidationMode
    public enum ValidationMode: String, Codable, Equatable {
        case error
        case warn
        case off
    }
}
