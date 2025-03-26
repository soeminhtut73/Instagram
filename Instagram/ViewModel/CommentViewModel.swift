//
//  CommentViewModel.swift
//  Instagram
//
//  Created by S M H  on 01/02/2025.
//

import UIKit

struct CommentViewModel {
    
    private let comment: Comment
    
    var profileImageURL: URL? {
        return URL(string: comment.profileImageURL)
    }
    
    var username: String {
        return comment.username
    }
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    func commentText() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: "\(username) ", attributes: [.foregroundColor: UIColor.label, .font : UIFont.boldSystemFont(ofSize: 12)])
        attributeString.append(NSAttributedString(string: comment.comment, attributes: [.foregroundColor: UIColor.secondaryLabel, .font : UIFont.systemFont(ofSize: 12)]))
        
        return attributeString
    }
    
    // set the comment cell size by text in one line and get the height of the cell
    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = comment.comment
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
