//
//  PTDataTableViewController.m
//  iPhoneSensorData
//
//  Created by CHEN KAIDI on 22/4/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "PTDataTableViewController.h"
#import "PTDataTableViewCell.h"

#define PT_LOG_FILEPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define MAX_LOG_FILE_SIZE 100000000 // Maximum log file size: 500 KB

@interface PTDataTableViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>{
    CGFloat accelerometerX, accelerometerY, accelerometerZ;
    CGFloat magnetometerX, magnetometerY, magnetometerZ;
    CGFloat gyroscopicX, gyroscopicY, gyroscopicZ;
    
    BOOL recording;
    BOOL blink;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIView *redDot;
@property (nonatomic, strong) NSString *currentPath;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) NSString *logMsg;
@property (nonatomic, strong) NSFileHandle *handle;
@end

static NSString *PTDataTableViewCellID = @"PTDataTableViewCellID";
@implementation PTDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    recording = NO;
    self.redDot.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.redDot];
    self.startButton.frame = CGRectMake(0, self.tableView.frame.size.height, self.view.bounds.size.width, 90);
    self.redDot.center = CGPointMake(self.startButton.center.x, self.startButton.center.y+(self.view.bounds.size.height-self.startButton.center.y)/2);
    [self startMyMotionDetect];
    [self.locationManager startUpdatingHeading];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.004 target:self selector:@selector(log) userInfo:nil repeats:YES];
//    [self.timer fire];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
}

-(NSString *)generateFilePath{
    return [PT_LOG_FILEPATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[self getCurrentDateString]]];
}

-(NSString *)getCurrentDateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    return stringFromDate;
}

-(void)toggleStart{
    if (!recording) {
        self.currentPath = [self generateFilePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.currentPath]) {
            [[NSFileManager defaultManager] createFileAtPath:self.currentPath contents:nil attributes:nil];
        }
        self.handle = [NSFileHandle fileHandleForWritingAtPath:self.currentPath];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.004 target:self selector:@selector(log) userInfo:nil repeats:YES];
        [self.timer fire];
        
        recording = YES;
        blink = YES;
        [self.startButton setTitle:@"STOP" forState:UIControlStateNormal];
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(blinkRedDot) userInfo:nil repeats:YES];
        [self.recordingTimer fire];
    }else{
        [self.timer invalidate];
        self.timer = nil;
        [self.handle closeFile];
        recording = NO;
        [self.startButton setTitle:@"START" forState:UIControlStateNormal];
        [self.recordingTimer invalidate];
        self.recordingTimer = nil;
        self.redDot.hidden = YES;
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:self.currentPath toPath:[self.currentPath stringByAppendingString:[NSString stringWithFormat:@" -> %@.txt",[self getCurrentDateString]]] error:&error];
    }
}

-(void)blinkRedDot{
    blink = !blink;
    self.redDot.hidden = blink;
}

-(void)append:(NSString *)msg{
    // create if needed
//    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:PT_LOG_FILEPATH error:nil] fileSize];
//    if (fileSize > MAX_LOG_FILE_SIZE) {
//        NSFileManager *fileManager= [NSFileManager defaultManager];
//        [fileManager removeItemAtPath:PT_LOG_FILEPATH error:nil];
//        [[NSFileManager defaultManager] createFileAtPath:PT_LOG_FILEPATH contents:nil attributes:nil];
//    }

    // append
    
    [self.handle truncateFileAtOffset:[self.handle seekToEndOfFile]];
    [self.handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    
}

-(void)log{
    NSDateFormatter *formatter;
    NSString  *dateString;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss:SSS"];
    dateString = [formatter stringFromDate:[NSDate date]];
    
    self.logMsg = [NSString stringWithFormat:@"[%@]A:%.3f,%.3f,%f M:%.3f,%.3f,%.3f G:%.3f,%.3f,%.3f\n",dateString,accelerometerX,accelerometerY,accelerometerZ,magnetometerX,magnetometerY,magnetometerZ,gyroscopicX,gyroscopicY,gyroscopicZ];
    //NSLog(@"%@",self.logMsg);
    [self append:self.logMsg];
}

- (void)startMyMotionDetect{
    
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error){
         accelerometerX = data.acceleration.x;
         accelerometerY = data.acceleration.y;
         accelerometerZ = data.acceleration.z;
         dispatch_async(dispatch_get_main_queue(),^{
             [self.tableView reloadData];
        });
     }];

    [self.motionManager
     startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMDeviceMotion *gyroData, NSError *error) {
         gyroscopicX = gyroData.attitude.yaw;
         gyroscopicY = gyroData.attitude.pitch;
         gyroscopicZ = gyroData.attitude.roll;
         dispatch_async(dispatch_get_main_queue(),^{
             [self.tableView reloadData];
         });
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    magnetometerX = heading.x;
    magnetometerY = heading.y;
    magnetometerZ = heading.z;
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.height/3-30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PTDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PTDataTableViewCellID forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:{
            [cell setAttirbuteWithX:accelerometerX y:accelerometerY z:accelerometerZ sensorName:@"(加速度计) Accelerometer" xTitle:@"X" yTitle:@"Y" zTitle:@"Z"];
            break;
        }
        case 1:{
            [cell setAttirbuteWithX:magnetometerX y:magnetometerY z:magnetometerZ sensorName:@"(磁力计) Magnetometer" xTitle:@"X" yTitle:@"Y" zTitle:@"Z"];
            break;
        }
        case 2:{
            [cell setAttirbuteWithX:gyroscopicX y:gyroscopicY z:gyroscopicZ sensorName:@"(陀螺仪) Gyroscopic Sensor" xTitle:@"Yaw" yTitle:@"Pitch" zTitle:@"Roll"];
            break;
        }
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-100) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PTDataTableViewCell class] forCellReuseIdentifier:PTDataTableViewCellID];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

-(UIButton *)startButton{
    if (!_startButton) {
        _startButton = [[UIButton alloc] init];
        [_startButton setTitle:@"START" forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(toggleStart) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

-(UIView *)redDot{
    if (!_redDot) {
        _redDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _redDot.backgroundColor = [UIColor redColor];
        _redDot.layer.cornerRadius = 4;
    }
    return _redDot;
}

- (CMMotionManager *)motionManager{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.headingFilter = kCLHeadingFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

@end
