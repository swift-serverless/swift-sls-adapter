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

// MARK: - ServerlessConfigPackage

/// Package
public struct Package: Codable, Equatable {
    /// Initialise a Package configuration
    ///
    /// - Parameters:
    ///   - patterns: Directories and files to include in the deployed package
    ///   - individually: Package each function as an individual artifact (default: false)
    ///   - artifact: Explicitly set the package artifact to deploy (overrides native packaging behavior)
    public init(
        patterns: [String]?,
        individually: Bool?,
        artifact: String?
    ) {
        self.patterns = patterns
        self.individually = individually
        self.artifact = artifact
    }

    /// Directories and files to include in the deployed package
    public let patterns: [String]?

    /// Package each function as an individual artifact (default: false)
    public let individually: Bool?

    /// Explicitly set the package artifact to deploy (overrides native packaging behavior)
    ///
    /// example: path/to/my-artifact.zip
    public let artifact: String?
}
