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

// MARK: - ProductsTable

/// Resource configuration
public struct Resource: Codable {
    /// Initialise a Resource configuration
    ///
    /// - Parameters:
    ///   - type: Resource type
    ///   - properties: Resource YAML properties
    public init(type: String, properties: YAMLContent) {
        self.type = type
        self.properties = properties
    }

    /// Resource type
    public let type: String
    
    /// Resource YAML properties
    public let properties: YAMLContent

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case properties = "Properties"
    }
}

extension Resource {
    /// Build a DynamoDB Resource with billing mode PAY_PER_REQUEST
    ///
    /// - Parameters:
    ///   - tableName: DynamoDB table name
    ///   - key: DynamoDB key
    /// - Returns: Resource
    public static func DynamoDBResorce(tableName: String, key: String) throws -> Resource {
        return Resource(
            type: "AWS::DynamoDB::Table",
            properties: try YAMLContent.DynamoDBProperties(tableName: tableName, key: key)
        )
    }
}

extension YAMLContent {
    /// DynamoDB YAML properties
    ///
    /// Billing mode PAY_PER_REQUEST
    /// see: https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BillingModeSummary.html
    /// - Parameters:
    ///   - tableName: DynamoDB table name
    ///   - key: DynamoDB key name
    /// - Returns: YAMLContent
    public static func DynamoDBProperties(tableName: String, key: String) throws -> YAMLContent {
        let properties: [String: AnyHashable] = [
            "TableName": tableName,
            "AttributeDefinitions": [
                "AttributeName": key,
                "AttributeType": "S"
            ],
            "KeySchema": [
                ["AttributeName": key],
                ["KeyType": "HASH"]
            ],
            "BillingMode": "PAY_PER_REQUEST"
        ]
        return try YAMLContent(with: properties)
    }
}
