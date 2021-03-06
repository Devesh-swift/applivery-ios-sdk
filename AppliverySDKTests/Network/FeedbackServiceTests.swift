//
//  FeedbackServiceTests.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez Agudo on 22/10/16.
//  Copyright © 2016 Applivery S.L. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Applivery

class FeedbackServiceTests: XCTestCase {
	
	var feedbackService: FeedbackService!
	
	var appMock: AppMock!
	var deviceMock: DeviceMock!
	var configMock: GlobalConfig!
	
	override func setUp() {
		super.setUp()
		
		self.appMock = AppMock()
		self.deviceMock = DeviceMock()
		self.configMock = GlobalConfig()
		
		self.feedbackService = FeedbackService(
			app: self.appMock,
			device: self.deviceMock,
			config: self.configMock
		)
	}
	
	override func tearDown() {
		self.feedbackService = nil
		
		self.appMock = nil
		self.deviceMock = nil
		self.configMock = nil
		
		OHHTTPStubs.removeAllStubs()
		
		super.tearDown()
	}
	
	func test_not_nil() {
		XCTAssertNotNil(self.feedbackService)
	}
	
	func test_postFeedback_buildTheRequest() {
		self.stubFeedbackOK()
		self.setupConfigAndApp()
		self.setupDeviceWithBattery()
		
		let feedback = Feedback(feedbackType: .bug, message: "TEST_MESSAGE", screenshot: nil)
		
		let completionCalled = self.expectation(description: "completion called")
		self.feedbackService.postFeedback(feedback) { _ in
			completionCalled.fulfill()
		}
		
		XCTAssert(self.feedbackService.request?.endpoint == "/api/feedback")
		XCTAssert(self.feedbackService.request?.method == "POST")
		
		let expectedBody: [String: Any] = [
			"app": "TEST_ID",
			"type": "bug",
			"message": "TEST_MESSAGE",
			"packageInfo": [
				"name": "TEST_BUNDLE_ID",
				"version": "TEST_VERSION",
				"versionName": "TEST_VERSION_NAME"
			],
			"deviceInfo": [
				"device": [
					"model": "TEST MODEL",
					"vendor": "Apple",
					"type": "TEST TYPE",
					"id": "test vendor",
					"network": "test network type",
					"resolution": "test resolution",
					"ramUsed": "50",
					"ramTotal": "2000",
					"diskFree": "test disk free",
					"orientation": "test orientation",
					 "battery": 30,
					 "batteryStatus": true
				],
				"os": [
					"name": "iOS",
					"version": "TEST IOS VERSION"
				]
			],
			"screenshot": ""
		]
		
		XCTAssert(self.feedbackService.request!.bodyParams == expectedBody)
		XCTAssert(self.feedbackService.request?.urlParams == [:])
		
		self.waitForExpectations(timeout: 1) { _ in }
	}
	
	func test_postFeedback_buildTheRequest_withoutBattery() {
		self.stubFeedbackOK()
		self.setupConfigAndApp()
		self.setupDeviceWithoutBattery()
		
		let feedback = Feedback(feedbackType: .bug, message: "TEST_MESSAGE", screenshot: nil)
		
		let completionCalled = self.expectation(description: "completion called")
		self.feedbackService.postFeedback(feedback) { _ in
			completionCalled.fulfill()
		}
		
		XCTAssert(self.feedbackService.request?.endpoint == "/api/feedback")
		XCTAssert(self.feedbackService.request?.method == "POST")
		
		let expectedBody: [String: Any] = [
			"app": "TEST_ID",
			"type": "bug",
			"message": "TEST_MESSAGE",
			"packageInfo": [
				"name": "TEST_BUNDLE_ID",
				"version": "TEST_VERSION",
				"versionName": "TEST_VERSION_NAME"
			],
			"deviceInfo": [
				"device": [
					"model": "TEST MODEL",
					"vendor": "Apple",
					"type": "TEST TYPE",
					"id": "test vendor",
					"network": "test network type",
					"resolution": "test resolution",
					"ramUsed": "50",
					"ramTotal": "2000",
					"diskFree": "test disk free",
					"orientation": "test orientation"
				],
				"os": [
					"name": "iOS",
					"version": "TEST IOS VERSION"
				]
			],
			"screenshot": ""
		]
		
		XCTAssert(self.feedbackService.request!.bodyParams == expectedBody)
		XCTAssert(self.feedbackService.request?.urlParams == [:])
		
		self.waitForExpectations(timeout: 1) { _ in }
	}
	
	func test_postFeedback_resultSuccess_whenJSONisOK() {
		self.stubFeedbackOK()
		self.setupConfigAndApp()
		self.setupDeviceWithBattery()
		
		let feedback = Feedback(feedbackType: .bug, message: "TEST_MESSAGE", screenshot: nil)
		
		let completionCalled = self.expectation(description: "completion called")
		self.feedbackService.postFeedback(feedback) { result in
			XCTAssert(result == Result.success(true))
			
			completionCalled.fulfill()
		}
		
		self.waitForExpectations(timeout: 1) { _ in }
	}
	
	func test_postFeedback_resultUnexpectedError_whenJSONisKO() {
		self.stubFeedbackKO()
		self.setupConfigAndApp()
		self.setupDeviceWithBattery()
		
		let feedback = Feedback(feedbackType: .bug, message: "TEST_MESSAGE", screenshot: nil)
		
		let completionCalled = self.expectation(description: "completion called")
		self.feedbackService.postFeedback(feedback) { result in
			XCTAssert(result == Result.error(NSError.unexpectedError()))
			
			completionCalled.fulfill()
		}
		
		self.waitForExpectations(timeout: 1) { _ in }
	}
	
	
	// MARK: - Private Helpers
	
	private func setupConfigAndApp() {
		self.configMock.appId = "TEST_ID"
		self.appMock.stubBundleID = "TEST_BUNDLE_ID"
		self.appMock.stubVersion = "TEST_VERSION"
		self.appMock.stubVersionName = "TEST_VERSION_NAME"
	}
	
	private func setupDeviceWithBattery() {
		self.setupDeviceWithoutBattery()
		self.deviceMock.fakeBatteryLevel = 30
		self.deviceMock.fakeBatteryState = true
	}
	
	private func setupDeviceWithoutBattery() {
		self.deviceMock.fakeModel = "TEST MODEL"
		self.deviceMock.fakeType = "TEST TYPE"
		self.deviceMock.fakeSystemVersion = "TEST IOS VERSION"
		self.deviceMock.fakeVendorId = "test vendor"
		self.deviceMock.fakeBatteryLevel = 30
		self.deviceMock.fakeBatteryState = nil
		self.deviceMock.fakeNetworkType = "test network type"
		self.deviceMock.fakeResolution = "test resolution"
		self.deviceMock.fakeOrientation = "test orientation"
		self.deviceMock.fakeDiskFree = "test disk free"
		self.deviceMock.fakeRamUsed = "50"
		self.deviceMock.fakeRamTotal = "2000"
	}
	
	private func stubFeedbackOK() {
		_ = stub(condition: isPath("/api/feedback")) { _ in
			return StubResponse.stubResponse(with: "feedback_ok.json")
		}
	}
	
	private func stubFeedbackKO() {
		_ = stub(condition: isPath("/api/feedback")) { _ in
			return StubResponse.stubResponse(with: "ko.json")
		}
	}
}
