//
//  PTDataTableViewCell.m
//  iPhoneSensorData
//
//  Created by CHEN KAIDI on 22/4/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import "PTDataTableViewCell.h"
#define kLabelHorizontalInset 10
@interface PTDataTableViewCell ()
@property (nonatomic, strong) UILabel *sensorName;
@property (nonatomic, strong) UILabel *xTitleLabel, *yTitleLabel, *zTitleLabel;
@property (nonatomic, strong) UILabel *xDataLabel, *yDataLabel, *zDataLabel;
@end

@implementation PTDataTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
        [self.contentView addSubview:self.sensorName];
        [self.contentView addSubview:self.xTitleLabel];
        [self.contentView addSubview:self.yTitleLabel];
        [self.contentView addSubview:self.zTitleLabel];
        [self.contentView addSubview:self.xDataLabel];
        [self.contentView addSubview:self.yDataLabel];
        [self.contentView addSubview:self.zDataLabel];
        self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

-(void)setAttirbuteWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z sensorName:(NSString *)name xTitle:(NSString *)xTitle yTitle:(NSString *)yTitle zTitle:(NSString *)zTitle{
    self.sensorName.text = name;
    self.xDataLabel.text = [NSString stringWithFormat:@"%.3f",x];
    self.yDataLabel.text = [NSString stringWithFormat:@"%.3f",y];
    self.zDataLabel.text = [NSString stringWithFormat:@"%.3f",z];
    self.xTitleLabel.text = xTitle;
    self.yTitleLabel.text = yTitle;
    self.zTitleLabel.text = zTitle;
    [self layoutSubviews];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.sensorName.frame = CGRectMake(kLabelHorizontalInset, kLabelHorizontalInset, self.bounds.size.width-kLabelHorizontalInset*2, self.sensorName.font.lineHeight);
    CGFloat dataLabelSize = (self.bounds.size.width-kLabelHorizontalInset*4)/3;
    self.xDataLabel.frame = CGRectMake(kLabelHorizontalInset, (self.bounds.size.height-dataLabelSize)/2, dataLabelSize, dataLabelSize);
    self.yDataLabel.frame = CGRectMake(self.xDataLabel.frame.origin.x+self.xDataLabel.frame.size.width+kLabelHorizontalInset, (self.bounds.size.height-dataLabelSize)/2, dataLabelSize, dataLabelSize);
    self.zDataLabel.frame = CGRectMake(self.yDataLabel.frame.origin.x+self.xDataLabel.frame.size.width+kLabelHorizontalInset, (self.bounds.size.height-dataLabelSize)/2, dataLabelSize, dataLabelSize);
    self.xTitleLabel.frame = CGRectMake(self.xDataLabel.frame.origin.x, self.xDataLabel.frame.origin.y+self.xDataLabel.frame.size.height, self.xDataLabel.frame.size.width, self.xTitleLabel.font.lineHeight+10);
    self.yTitleLabel.frame = CGRectMake(self.yDataLabel.frame.origin.x, self.yDataLabel.frame.origin.y+self.yDataLabel.frame.size.height, self.yDataLabel.frame.size.width, self.yTitleLabel.font.lineHeight+10);
    self.zTitleLabel.frame = CGRectMake(self.zDataLabel.frame.origin.x, self.zDataLabel.frame.origin.y+self.zDataLabel.frame.size.height, self.zDataLabel.frame.size.width, self.zTitleLabel.font.lineHeight+10);
}

-(UILabel *)sensorName{
    if (!_sensorName) {
        _sensorName = [[UILabel alloc] init];
        _sensorName.font = [UIFont systemFontOfSize:22];
        _sensorName.textColor = [UIColor whiteColor];
    }
    return _sensorName;
}

-(UILabel *)xTitleLabel{
    if (!_xTitleLabel) {
        _xTitleLabel = [[UILabel alloc] init];
        _xTitleLabel.textAlignment = NSTextAlignmentCenter;
        _xTitleLabel.font = [UIFont systemFontOfSize:18];
        _xTitleLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        _xTitleLabel.text = @"X";
    }
    return _xTitleLabel;
}

-(UILabel *)yTitleLabel{
    if (!_yTitleLabel) {
        _yTitleLabel = [[UILabel alloc] init];
        _yTitleLabel.textAlignment = NSTextAlignmentCenter;
        _yTitleLabel.font = [UIFont systemFontOfSize:18];
        _yTitleLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        _yTitleLabel.text = @"Y";
    }
    return _yTitleLabel;
}

-(UILabel *)zTitleLabel{
    if (!_zTitleLabel) {
        _zTitleLabel = [[UILabel alloc] init];
        _zTitleLabel.textAlignment = NSTextAlignmentCenter;
        _zTitleLabel.font = [UIFont systemFontOfSize:18];
        _zTitleLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        _zTitleLabel.text = @"Z";
    }
    return _zTitleLabel;
}

-(UILabel *)xDataLabel{
    if (!_xDataLabel) {
        _xDataLabel = [[UILabel alloc] init];
        _xDataLabel.textAlignment = NSTextAlignmentCenter;
        _xDataLabel.font = [UIFont systemFontOfSize:20];
        _xDataLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        _xDataLabel.textColor = [UIColor whiteColor];
        _xDataLabel.layer.cornerRadius = 8;
        _xDataLabel.layer.masksToBounds = YES;
    }
    return _xDataLabel;
}

-(UILabel *)yDataLabel{
    if (!_yDataLabel) {
        _yDataLabel = [[UILabel alloc] init];
        _yDataLabel.textAlignment = NSTextAlignmentCenter;
        _yDataLabel.font = [UIFont systemFontOfSize:20];
        _yDataLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        _yDataLabel.textColor = [UIColor whiteColor];
        _yDataLabel.layer.cornerRadius = 8;
        _yDataLabel.layer.masksToBounds = YES;
    }
    return _yDataLabel;
}

-(UILabel *)zDataLabel{
    if (!_zDataLabel) {
        _zDataLabel = [[UILabel alloc] init];
        _zDataLabel.textAlignment = NSTextAlignmentCenter;
        _zDataLabel.font = [UIFont systemFontOfSize:20];
        _zDataLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        _zDataLabel.textColor = [UIColor whiteColor];
        _zDataLabel.layer.cornerRadius = 8;
        _zDataLabel.layer.masksToBounds = YES;
    }
    return _zDataLabel;
}

@end
