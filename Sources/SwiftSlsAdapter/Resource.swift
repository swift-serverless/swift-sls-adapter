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

public struct Resources {
    /// Build Resources
    /// - Parameter with: Resource dictionary
    /// - Returns: [String: AnyHashable]
    public static func resources(with dictionary: [String: [String: AnyHashable]]) -> [String: AnyHashable] {
        return ["Resources": dictionary]
    }
}

/// Resource builder
public struct Resource {
    /// Build a Resource
    ///
    /// - Parameters:
    ///   - type: Type
    ///   - properties: Properties
    /// - Returns: [String: AnyHashable]
    public static func resource(type: String, properties: [String: AnyHashable]) -> [String: AnyHashable] {
        return ["Type": type,
                "Properties": properties]
    }
    
    /// Build a DynamoDB Resource with billing mode PAY_PER_REQUEST
    ///
    /// - Parameters:
    ///   - tableName: DynamoDB table name
    ///   - key: DynamoDB key
    /// - Returns: [String: AnyHashable]
    public static func dynamoDBResource(tableName: String, key: String) -> [String: AnyHashable] {
        return Resource.resource(
            type: "AWS::DynamoDB::Table",
            properties: Resource.dynamoDBProperties(tableName: tableName, key: key)
        )
    }

    /// DynamoDB YAML properties
    ///
    /// Billing mode PAY_PER_REQUEST
    /// see: https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BillingModeSummary.html
    /// - Parameters:
    ///   - tableName: DynamoDB table name
    ///   - key: DynamoDB key name
    /// - Returns: [String: AnyHashable]
    public static func dynamoDBProperties(tableName: String, key: String) -> [String: AnyHashable] {
        return [
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
    }
}
