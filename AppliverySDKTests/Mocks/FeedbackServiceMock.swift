//
//  FeedbackServiceMock.swift
//  AppliverySDK
//
//  Created by Alejandro Jiménez on 16/4/16.
//  Copyright © 2016 Applivery S.L. All rights reserved.
//

import Foundation
@testable import Applivery


class FeedbackServiceMock: PFeedbackService {
	
	// Inputs
	var inResult: FeedbackServiceResult!
	
	
	// Outputs
	var outPostFeedback: (called: Bool, feedback: Feedback?) = (false, nil)
	
	
	func postFeedback(feedback: Feedback, completionHandler: FeedbackServiceResult -> Void) {
		self.outPostFeedback = (true, feedback)
		completionHandler(self.inResult)
	}
	
}