//
//  SKSConfiguration.swift
//  SpeechKitSample
//
//  All Nuance Developers configuration parameters can be set here.
//
//  Copyright (c) 2015 Nuance Communications. All rights reserved.
//

import Foundation

var SKSAppKey = "f5545062ece11b5f411f1408259376a8e10997686754720e3f8b63ca364acb2b9e1c8e8afda9e93ec8fe46ed91bc9572c62cda2d804d3cc0d89f8a0ee9563a87"
var SKSAppId = "NMDPTRIAL_xd2164_tc_columbia_edu20161119150058"
var SKSServerHost = "nmsps.dev.nuance.com"
var SKSServerPort = "443"

var SKSLanguage = "eng-USA"

var SKSServerUrl = String(format: "nmsps://%@@%@:%@", SKSAppId, SKSServerHost, SKSServerPort)

// Only needed if using NLU/Bolt
var SKSNLUContextTag = "M4432_A2131"


let LANGUAGE = SKSLanguage == "eng-USA" ? "eng-USA" : SKSLanguage