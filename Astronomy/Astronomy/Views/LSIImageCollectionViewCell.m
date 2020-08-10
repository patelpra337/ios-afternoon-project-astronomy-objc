//
//  LSIImageCollectionViewCell.m
//  Astronomy
//
//  Created by patelpra on 8/10/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

#import "LSIImageCollectionViewCell.h"

@implementation LSIImageCollectionViewCell

- (void)prepareForReuse
{
    self.marsImageView.image = [UIImage imageNamed:@"MarsPlaceholder"];
}

@end
