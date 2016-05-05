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

#define PT_LOG_FILEPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"PTlogfile.txt"]

#define MAX_LOG_FILE_SIZE 100000000 // Maximum log file size: 500 KB

@interface PTDataTableViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>{
    CGFloat accelerometerX, accelerometerY, accelerometerZ;
    CGFloat magnetometerX, magnetometerY, magnetometerZ;
    CGFloat gyroscopicX, gyroscopicY, gyroscopicZ;
    
    
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *logMsg;
@property (nonatomic, strong) NSFileHandle *handle;
@end

static NSString *PTDataTableViewCellID = @"PTDataTableViewCellID";
@implementation PTDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    [self startMyMotionDetect];
    [self.locationManager startUpdatingHeading];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.004 target:self selector:@selector(log) userInfo:nil repeats:YES];
    [self.timer fire];
    if (![[NSFileManager defaultManager] fileExistsAtPath:PT_LOG_FILEPATH]) {
        [[NSFileManager defaultManager] createFileAtPath:PT_LOG_FILEPATH contents:nil attributes:nil];
    }
    self.handle = [NSFileHandle fileHandleForWritingAtPath:PT_LOG_FILEPATH];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self.handle closeFile];
}

-(void)append:(NSString *)msg{
    // create if needed
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:PT_LOG_FILEPATH error:nil] fileSize];
    if (fileSize > MAX_LOG_FILE_SIZE) {
        NSFileManager *fileManager= [NSFileManager defaultManager];
        [fileManager removeItemAtPath:PT_LOG_FILEPATH error:nil];
        [[NSFileManager defaultManager] createFileAtPath:PT_LOG_FILEPATH contents:nil attributes:nil];
    }

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
    return [UIScreen mainScreen].bounds.size.height/3;
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
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PTDataTableViewCell class] forCellReuseIdentifier:PTDataTableViewCellID];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
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
