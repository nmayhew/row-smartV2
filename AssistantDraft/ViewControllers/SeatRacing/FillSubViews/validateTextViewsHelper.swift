//
//  validate.swift
//  AssistantDraft
//
//  Created by Nicholas Mayhew on 03/08/2019.
//  Copyright © 2019 Mayhew. All rights reserved.
//

import Foundation
import UIKit
struct validationFun {
    static func validate(_ textViews: [UITextField]) -> [UITextField] {
        var failedTextViews: [UITextField] = []
        for textView in textViews {
            let text = textView.text
            
            if (text!.trimmingCharacters(in:    CharacterSet.whitespacesAndNewlines).isEmpty) {
                failedTextViews.append(textView)
            }
            
        }
        return failedTextViews
    }
}
