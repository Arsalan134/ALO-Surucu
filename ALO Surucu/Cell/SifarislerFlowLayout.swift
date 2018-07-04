//
//  SifarislerFlowLayout.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 05.06.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation
import UIKit

class SifarislerFlowLayout: UICollectionViewFlowLayout {
    var numberOfCellsInRow: Int = 1

    init(numberOfColumns: Int) {
        super.init()

        minimumLineSpacing = 20
        minimumInteritemSpacing = 10
        numberOfCellsInRow = numberOfColumns
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var itemSize: CGSize {
        get {
            if collectionView != nil {
                sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)

                let widthOfCell = (UIScreen.main.bounds.width - sectionInset.left - sectionInset.right - (CGFloat(numberOfCellsInRow - 1) * minimumInteritemSpacing)) / CGFloat(numberOfCellsInRow)
                return CGSize(width: widthOfCell, height: widthOfCell / 2.5)
            }

            // Default fallback
            return CGSize(width: 100, height: 100)
        }
        set {
            super.itemSize = newValue
        }
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }

}

