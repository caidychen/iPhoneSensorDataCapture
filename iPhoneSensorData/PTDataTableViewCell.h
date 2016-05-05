//
//  PTDataTableViewCell.h
//  iPhoneSensorData
//
//  Created by CHEN KAIDI on 22/4/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTDataTableViewCell : UITableViewCell

-(void)setAttirbuteWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z sensorName:(NSString *)name xTitle:(NSString *)xTitle yTitle:(NSString *)yTitle zTitle:(NSString *)zTitle;

@end
