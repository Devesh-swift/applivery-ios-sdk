//
//  FeedbackPresenterTests.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez on 21/4/16.
//  Copyright © 2016 Applivery S.L. All rights reserved.
//

import XCTest
@testable import Applivery


class FeedbackPresenterTests: XCTestCase {

	var feedbackPresenter: FeedbackPresenter!
	var screenshotInteractorMock: ScreenshotInteractorMock!
	var feedbackViewMock: FeedbackViewMock!
	var feedbackCoordinatorMock: FeedbackCoordinatorMock!
	var feedbackInteractorMock: FeedbackInteractorMock!


    override func setUp() {
        super.setUp()

		self.feedbackPresenter = FeedbackPresenter()

		self.screenshotInteractorMock = ScreenshotInteractorMock()
		self.feedbackPresenter.screenshotInteractor = self.screenshotInteractorMock

		self.feedbackViewMock = FeedbackViewMock()
		self.feedbackPresenter.view = self.feedbackViewMock

		self.feedbackCoordinatorMock = FeedbackCoordinatorMock()
		self.feedbackPresenter.feedbackCoordinator = self.feedbackCoordinatorMock

		self.feedbackInteractorMock = FeedbackInteractorMock()
		self.feedbackPresenter.feedbackInteractor = self.feedbackInteractorMock
    }

    override func tearDown() {
		self.feedbackPresenter = nil
		self.screenshotInteractorMock = nil
		self.feedbackViewMock = nil
		self.feedbackCoordinatorMock = nil
		self.feedbackInteractorMock = nil

        super.tearDown()
    }


    func test_not_nil() {
        XCTAssertNotNil(self.feedbackPresenter)
    }

	func test_viewDidLoad() {
		let image = UIImage()
		self.screenshotInteractorMock.inScreenshot = Screenshot(image: image)

		self.feedbackPresenter.viewDidLoad()

		XCTAssert(self.feedbackViewMock.outShowScreenshot.called == true)
		XCTAssert(self.feedbackViewMock.outShowScreenshot.image == image)
	}

	func test_userDidTapCloseButton() {
		self.feedbackPresenter.userDidTapCloseButton()

		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == true)
	}

	func test_userDidTapAddFeedbackButton() {
		let editedScreenshot = UIImage()
		self.feedbackViewMock.inEditedScreenshot = editedScreenshot
		
		self.feedbackPresenter.userDidTapAddFeedbackButton()

		XCTAssert(self.feedbackViewMock.outShowFeedbackFormulary.called == true)
		XCTAssert(self.feedbackViewMock.outShowFeedbackFormulary.preview == editedScreenshot)
	}


	// MARK - Tests change attach screenshot

	func test_userDidChangeAttachScreenshot_callsShowScreenshotPreview_whenOnIsTrue() {
		self.feedbackPresenter.userDidChangedAttachScreenshot(attach: true)

		XCTAssert(self.feedbackViewMock.outShowScreenshotPreviewCalled == true)
		XCTAssert(self.feedbackViewMock.outHideScreenshotPreviewCalled == false)
	}

	func test_userDidChangedAttachScreenshot_callsHideScreenshotPreview_whenOnIsFalse() {
		self.feedbackPresenter.userDidChangedAttachScreenshot(attach: false)

		XCTAssert(self.feedbackViewMock.outShowScreenshotPreviewCalled == false)
		XCTAssert(self.feedbackViewMock.outHideScreenshotPreviewCalled == true)
	}


	// MARK - Tests send feedback

	func test_userDidTapSendFeedbackButton_callsNeedMessage_whenViewHasNoMessage() {
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == true)
	}

	func test_userDidTapSendFeedbackButton_closeFeedback_whenSuccess() {
		// ARRANGE
		self.feedbackViewMock.inMessage = "test message"
		self.feedbackInteractorMock.inResult = .success


		// ACT
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		// ASSERT
		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == false)
		XCTAssert(self.feedbackViewMock.outShowLoadingCalled == true)
		XCTAssert(self.feedbackViewMock.outStopLoadingCalled == true)
		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.called == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.message == "test message")
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.feedbackType == .bug)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.screenshot == nil)
		XCTAssert(self.feedbackViewMock.outShowMessage.called == false)
	}

	func test_userDidTapSendFeedbackButton_showErrorMessage_whenError() {
		// ARRANGE
		self.feedbackViewMock.inMessage = "test message"
		self.feedbackInteractorMock.inResult = .error("test error")


		// ACT
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		// ASSERT
		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == false)
		XCTAssert(self.feedbackViewMock.outShowLoadingCalled == true)
		XCTAssert(self.feedbackViewMock.outStopLoadingCalled == false)
		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == false)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.called == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.message == "test message")
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.feedbackType == .bug)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.screenshot == nil)
		XCTAssert(self.feedbackViewMock.outShowMessage.called == true)
		XCTAssert(self.feedbackViewMock.outShowMessage.message == "test error")
	}

	func test_userDidTapSendFeedbackButton_feedbackSentIsBugType_whenSelectedBugType() {
		// ARRANGE
		self.feedbackViewMock.inMessage = "test message"
		self.feedbackInteractorMock.inResult = .success

		self.feedbackPresenter.userDidSelectedFeedbackType(.bug)


		// ACT
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		// ASSERT
		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == false)
		XCTAssert(self.feedbackViewMock.outShowLoadingCalled == true)
		XCTAssert(self.feedbackViewMock.outStopLoadingCalled == true)
		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.called == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.message == "test message")
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.feedbackType == .bug)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.screenshot == nil)
		XCTAssert(self.feedbackViewMock.outShowMessage.called == false)
	}

	func test_userDidTapSendFeedbackButton_feedbackSentIsFeedbackType_whenSelectedFeedbackType() {
		// ARRANGE
		self.feedbackViewMock.inMessage = "test message"
		self.feedbackInteractorMock.inResult = .success

		self.feedbackPresenter.userDidSelectedFeedbackType(.feedback)


		// ACT
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		// ASSERT
		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == false)
		XCTAssert(self.feedbackViewMock.outShowLoadingCalled == true)
		XCTAssert(self.feedbackViewMock.outStopLoadingCalled == true)
		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.called == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.message == "test message")
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.feedbackType == .feedback)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.screenshot == nil)
		XCTAssert(self.feedbackViewMock.outShowMessage.called == false)
	}

	func test_userDidTapSendFeedbackButton_feedbackSentHasScreenshot_whenAttachedScreenshot() {
		// ARRANGE
		self.feedbackViewMock.inMessage = "test message"
		self.feedbackInteractorMock.inResult = .success

		let image = UIImage()
		let editedImage = UIImage()
		self.screenshotInteractorMock.inScreenshot = Screenshot(image: image)
		self.feedbackViewMock.inEditedScreenshot = editedImage


		// ACT
		self.feedbackPresenter.viewDidLoad()
		self.feedbackPresenter.userDidTapAddFeedbackButton()
		self.feedbackPresenter.userDidChangedAttachScreenshot(attach: true)
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		// ASSERT
		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == false)
		XCTAssert(self.feedbackViewMock.outShowLoadingCalled == true)
		XCTAssert(self.feedbackViewMock.outStopLoadingCalled == true)
		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.called == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.message == "test message")
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.feedbackType == .bug)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.screenshot?.image == editedImage)
		XCTAssert(self.feedbackViewMock.outShowMessage.called == false)
	}

	func test_userDidTapSendFeedbackButton_feedbackSentHasNoScreenshot_whenNoAttachedScreenshot() {
		// ARRANGE
		self.feedbackViewMock.inMessage = "test message"
		self.feedbackInteractorMock.inResult = .success

		let image = UIImage()
		self.screenshotInteractorMock.inScreenshot = Screenshot(image: image)
		self.feedbackPresenter.viewDidLoad()

		self.feedbackPresenter.userDidChangedAttachScreenshot(attach: false)

		// ACT
		self.feedbackPresenter.userDidTapSendFeedbackButton()

		// ASSERT
		XCTAssert(self.feedbackViewMock.outNeedMessageCalled == false)
		XCTAssert(self.feedbackViewMock.outShowLoadingCalled == true)
		XCTAssert(self.feedbackViewMock.outStopLoadingCalled == true)
		XCTAssert(self.feedbackCoordinatorMock.outCloseFeedbackCalled == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.called == true)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.message == "test message")
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.feedbackType == .bug)
		XCTAssert(self.feedbackInteractorMock.outSendFeedback.feedback?.screenshot == nil)
		XCTAssert(self.feedbackViewMock.outShowMessage.called == false)
	}
	
	func test_userDidTapPreview_resultViewShowScreenshotNil_andStateChangedToPreview() {
		self.feedbackPresenter.userDidTapPreview()
		
		XCTAssert(self.feedbackViewMock.outShowScreenshot.called == true)
		XCTAssert(self.feedbackViewMock.outShowScreenshot.image == nil)
	}
	
	func test_userDidShake_resultShowOriginalScreenshot_whenPreviewModeIsSet() {
		let originalImage = UIImage()
		self.screenshotInteractorMock.inScreenshot = Screenshot(image: originalImage)
		
		
		self.feedbackPresenter.viewDidLoad()
		self.feedbackPresenter.userDidShake()
		
		XCTAssert(self.feedbackViewMock.outShowScreenshot.called == true)
		XCTAssert(self.feedbackViewMock.outShowScreenshot.image == originalImage)
	}
	
	func test_userDidShake_resultNoShowScreenshot_whenFormularyModeIsSet() {
		// Arrange
		let originalImage = UIImage()
		let editedImage = UIImage()
		self.screenshotInteractorMock.inScreenshot = Screenshot(image: originalImage)
		self.feedbackViewMock.inEditedScreenshot = editedImage
		
		// Act
		self.feedbackPresenter.userDidTapAddFeedbackButton()
		self.feedbackPresenter.userDidShake()
		
		// Assert
		XCTAssert(self.feedbackViewMock.outShowScreenshot.called == false)
	}
	
	func test_userDidShake_resultShowOriginalScreenshot_whenFormularyModeIsSet_thenBackToPreview() {
		// Arrange
		let originalImage = UIImage()
		let editedImage = UIImage()
		self.screenshotInteractorMock.inScreenshot = Screenshot(image: originalImage)
		self.feedbackViewMock.inEditedScreenshot = editedImage
		
		// Act
		self.feedbackPresenter.viewDidLoad()
		self.feedbackPresenter.userDidTapAddFeedbackButton()
		self.feedbackPresenter.userDidTapPreview()
		self.feedbackPresenter.userDidShake()
		
		// Assert
		XCTAssert(self.feedbackViewMock.outShowScreenshot.called == true)
		XCTAssert(self.feedbackViewMock.outShowScreenshot.image == originalImage)
	}

}
