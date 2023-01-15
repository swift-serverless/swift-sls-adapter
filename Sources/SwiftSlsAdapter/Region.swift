/*
 Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-sprinter

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

// MARK: Region

/// Region
/// - AWS Region
public enum Region: String, Codable, CaseIterable {
    case us_east_1 = "us-east-1"
    case us_east_2 = "us-east-2"
    case us_west_1 = "us-west-1"
    case us_west_2 = "us-west-2"

    case us_gov_east_1 = "us-gov-east-1"
    case us_gov_west_1 = "us-gov-west-1"
    case us_iso_east_1 = "us-iso-east-1"
    case us_iso_west_1 = "us-iso-west-1"
    case us_isob_east_1 = "us-isob-east-1"

    case eu_central_1 = "eu-central-1"
    case eu_central_2 = "eu-central-2"
    case eu_north_1 = "eu-north-1"
    case eu_south_1 = "eu-south-1"
    case eu_south_2 = "eu-south-2"
    case eu_west_1 = "eu-west-1"
    case eu_west_2 = "eu-west-2"
    case eu_west_3 = "eu-west-3"

    case cn_north_1 = "cn-north-1"
    case cn_northwest_1 = "cn-northwest-1"

    case af_south_1 = "af-south-1"

    case ap_east_1 = "ap-east-1"
    case ap_northeast_1 = "ap-northeast-1"
    case ap_northeast_2 = "ap-northeast-2"
    case ap_northeast_3 = "ap-northeast-3"
    case ap_south_1 = "ap-south-1"
    case ap_south_2 = "ap-south-2"
    case ap_southeast_1 = "ap-southeast-1"
    case ap_southeast_2 = "ap-southeast-2"
    case ap_southeast_3 = "ap-southeast-3"

    case ca_central_1 = "ca-central-1"

    case me_central_1 = "me-central-1"
    case me_south_1 = "me-south-1"

    case sa_east_1 = "sa-east-1"
}
