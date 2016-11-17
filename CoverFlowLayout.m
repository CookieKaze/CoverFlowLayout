//
//  CoverFlowLayout.m
//  CoverFlowLayout
//
//  Created by Erin Luu on 2016-11-17.
//  Copyright © 2016 Erin Luu. All rights reserved.
//

#import "CoverFlowLayout.h"

@implementation CoverFlowLayout

-(void)prepareLayout {
    CGSize viewSize = self.collectionView.frame.size;
    //Set horizontal scroll
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //Cell width is a third of the screen width. Height is half of the screen height.
    self.itemSize = CGSizeMake(viewSize.width/3, viewSize.height/2);
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    //Create array that holds all the attributes of the cells
    NSArray * original = [super layoutAttributesForElementsInRect:rect];
    //Needed to make a copy of the array because of error below
    //UICollectionViewFlowLayout has cached frame mismatch for index path...
    NSArray * attributes = [[NSArray alloc] initWithArray:original copyItems:YES];
    //Get the visible view rect
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    //Get the middle of the screen
    float middleOfScreen = self.collectionView.frame.size.width/2.0;
    
    //Loop through all of the attributes
    for (UICollectionViewLayoutAttributes* attribute in attributes) {
        //If the cell overlaps the visible screen
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            //Get cell center distance from the center of the screen
            //CGRectGetMidX(visibleRect)) is just (visibleRect.size.width/2)+visibleRect.origin.x)
            CGFloat distance = CGRectGetMidX(visibleRect) - attribute.center.x;
            CGFloat normalizedDistance= distance / middleOfScreen;
            
            //If center of cell is left or right of the center of the screen
            if (ABS(distance) < middleOfScreen) {
                //Set zoom value
                CGFloat zoom = 1 + (0.75 * (1 - ABS(normalizedDistance)));
                CATransform3D zoomTransform = CATransform3DMakeScale(zoom, zoom, 1.0);
                attribute.transform3D = zoomTransform;
                
                //Set fading alpha value
                CGFloat alphaValue = (1 - ABS(normalizedDistance)) + 0.1;
                if (alphaValue > 1) alphaValue = 1;
                attribute.alpha = alphaValue;
                
                //Fix center overlap
                attribute.zIndex = (1-ABS(normalizedDistance))*10;
            }
            else
            {
                //If middle is off screen then hide
                attribute.alpha = 0;
            }
        }
    }
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
@end
