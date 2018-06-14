//
//  ViewController.m
//  ZipperDownDemo
//
//  Created by PacteraLF on 2018/5/17.
//  Copyright © 2018年 PacteraLF. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "SSZipArchive.h"
#import "MBProgressHUD.h"

#define kSW [UIScreen mainScreen].bounds.size.width
#define kSH [UIScreen mainScreen].bounds.size.height

/**
 定义内部类SCrollView，点击视图，退出键盘
 */
@interface TapScrollView : UIScrollView
@end
@implementation TapScrollView
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}
@end

//-----------------------------

@interface ViewController ()

@property (nonatomic, strong) TapScrollView *scrollView; //可滚动视图
@property (nonatomic, strong) UITextField *fileNameTf; //下载的文件名称
@property (nonatomic, strong) UIButton *createJsFileBtn; //创建一个js文件
@property (nonatomic, strong) UIButton *clearCacheFilesBtn; //清除cache文件下载文件
@property (nonatomic, strong) UIButton *updateUrlBtn; //更新URL
@property (nonatomic, strong) UIButton *downloadBtn; //下载文件按钮
@property (nonatomic, strong) UITextView *cacheListView; //cache文件下列表
@property (nonatomic, strong) NSMutableString *mstr; //存储文件下文件
@property (nonatomic, strong) UITextView *jsFileView; //js文件下列表

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建UI
    [self createUI];
    //给按钮添加事件
    [self btnAddTarget];
}

/**
 给按钮添加事件
 */
-(void)btnAddTarget{
    [self.createJsFileBtn addTarget:self action:@selector(createJsFileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearCacheFilesBtn addTarget:self action:@selector(clearCacheFilesBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.updateUrlBtn addTarget:self action:@selector(updateUrlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadBtn addTarget:self action:@selector(downloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //读取展示JS热修复文件的内容
    [self readJspathJS];
}


/**
 从沙盒读取JS文件的内容
 */
-(void)readJspathJS{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *hotPath = [cachePath stringByAppendingPathComponent:@"jspatch/hot.js"];
    BOOL isExist = [fileManager fileExistsAtPath:hotPath];
    if (isExist) {
        NSData *jsData = [NSData dataWithContentsOfFile:hotPath];
        NSString *jsStr = [[NSString alloc]initWithData:jsData encoding:NSUTF8StringEncoding];
        if (jsStr.length > 0) {
            self.jsFileView.text = jsStr;
        }else{
            self.jsFileView.text = @"读取的js文件为空";
        }
    }else{
        self.jsFileView.text = @"hot.js文件不存在";
    }
}

/**
 创建假设的JS热修复文件jspatch/hot.js
 */
-(void)createJsFileBtnClick:(UIButton *)sender{
    //hot.js
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //文件夹
    NSString *jsPath = [cachePath stringByAppendingPathComponent:@"jspatch"];
    if (![fileManager fileExistsAtPath:jsPath]) {
        BOOL isCreateSucc = [fileManager createDirectoryAtPath:jsPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (isCreateSucc) {
            NSLog(@"jspatch文件夹创建成功");
        }else{
            NSLog(@"jspatch文件夹创建成功");
        }
    }
    //文件
    NSString *hotPath = [cachePath stringByAppendingPathComponent:@"jspatch/hot.js"];
    BOOL isExist = [fileManager fileExistsAtPath:hotPath];
    if (!isExist) {
        NSData *dataString = [@"jjjjjjjjjj" dataUsingEncoding:NSUTF8StringEncoding];
        BOOL isSucc = [fileManager createFileAtPath:hotPath contents:dataString attributes:nil];
        if (isSucc) {
            [self showHub:@"jspatch/hot.js文件创建成功" Time:1];
        }else{
            [self showHub:@"jspatch/hot.js文件创建失败" Time:1];
        }
    }else{
        [self showHub:@"jspatch/hot.js文件已经存在" Time:1];
    }
    [self showList];
    [self readJspathJS];
}

///MARK: - BtnClick
-(void)clearCacheFilesBtnClick:(UIButton *)sender{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [self removeAllFile:cachePath];
    [self showHub:@"文件清除成功" Time:1];
    [self showList];
    [self readJspathJS];
}

-(void)updateUrlBtnClick:(UIButton *)sender{
    self.fileNameTf.text = @"../jspatch";
    if (self.fileNameTf.text.length > 0) {
        [self showHub:@"压缩文件名称更新成功" Time:1];
    }else{
        [self showHub:@"请填入压缩文件名称" Time:1];
    }
    [self readJspathJS];
}

///MARK: - Download Zip
-(void)downloadBtnClick:(UIButton *)sender{
    [self downloadZip];
}

-(void)downloadZip{
    MBProgressHUD *hud = [self showHub:@"正在下载中" Time:30];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *url1 = @"https://raw.githubusercontent.com/muzipiao/CommonResource/master/zip/hot.zip";
    
    //没有zip文件夹则创建zip文件夹
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *zipPath = [cachePath stringByAppendingPathComponent:@"zip"];
    if (![fileManager fileExistsAtPath:zipPath]) {
        BOOL isCreateSucc = [fileManager createDirectoryAtPath:zipPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (isCreateSucc) {
            hud.label.text = @"创建zip文件夹成功";
        }else{
            hud.label.text = @"创建zip文件夹失败";
        }
    }
    
    NSURL *zipURL = [NSURL URLWithString:url1];
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:zipURL];
    NSURLSessionDownloadTask *downloadTask= [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        NSString *path = [zipPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        //下载失败
        if (error) {
            //删除当前失败的压缩包
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
            NSEnumerator *e = [contents objectEnumerator];
            NSString *filename;
            NSString *extension = [NSString stringWithFormat:@"%@.zip",url1];
            while (filename = [e nextObject]) {
                NSLog(@"filename:%@",filename);
                if ([filename isEqualToString:extension]) {
                    [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:filename] error:NULL];
                }
            }
            NSLog(@"下载失败：%@",error);
            return ;
        }
        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
        NSString *htmlFilePath = [filePath path];// 将NSURL转成NSString
        NSString *defaF = @"default";
        if (self.fileNameTf.text.length > 0) {
            defaF = self.fileNameTf.text;
        }
        NSString *desPath = [NSString stringWithFormat:@"%@/%@",zipPath,defaF];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExist = [fileManager fileExistsAtPath:htmlFilePath];
        if (isExist) {
            NSLog(@"下载的文件已存在");
        }else{
            NSLog(@"下载的文件不存在");
        }
        //解压新的压缩文件
        BOOL isSuccess = [SSZipArchive unzipFileAtPath:htmlFilePath toDestination:desPath];
        // 压缩
        if (isSuccess) {
            hud.label.text = @"解压缩成功";
            NSLog(@"解压缩成功");
        }else{
            hud.label.text = @"解压缩失败";
            NSLog(@"解压缩失败");
        }
        
        [hud hideAnimated:YES afterDelay:2];
        [self showList];
        [self readJspathJS];
        
    }];
    [downloadTask resume];
}

///MARK: - 沙盒文件和文件夹操作
-(void)removeAllFile:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while (filename = [e nextObject]) {
        NSString *filePath = [path stringByAppendingPathComponent:filename];
        BOOL isDir;
        BOOL isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
        if (isExist) {
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
}

-(void)showList{
    self.mstr = [NSMutableString string]; //清空
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [self listPathFile:cachePath];
    self.cacheListView.text = self.mstr;
}

-(void)listPathFile:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while (filename = [e nextObject]) {
        NSString *filePath = [path stringByAppendingPathComponent:filename];
        BOOL isDir;
        BOOL isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
        if (isExist) {
            if (isDir) {
                //如果是目录
                NSString *f = [NSString stringWithFormat:@"文件夹%@,\n",filename];
                [self.mstr appendString:f];
                [self listPathFile:filePath];
            }else{
                //是文件
                [self.mstr appendFormat:@"文件%@,\n",filename];
            }
        }
    }
}

///MARK: - 弹窗
-(MBProgressHUD *)showHub:(NSString *)title Time:(NSTimeInterval)time{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    if (title) {
        hud.label.text = title;
    }else{
        hud.label.text = @"Loading";
    }
    [hud hideAnimated:YES afterDelay:time];
    return hud;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

///MARK: - 创建UI
-(void)createUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView = [[TapScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    //文件名称自命名
    UITextField *fName = [[UITextField alloc]initWithFrame:CGRectMake(15, 5, kSW - 30, 44)];
    fName.borderStyle = UITextBorderStyleRoundedRect;
    fName.placeholder = @"输入名称，更换压缩包文件名";
    [self.scrollView addSubview:fName];
    self.fileNameTf = fName;
    
    //在library/Caches文件夹下创建jspatch/hot.js的按钮
    CGFloat btnW = kSW / 3.0;
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.backgroundColor =  [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    btn1.frame = CGRectMake(0, 50, btnW, 44);
    [btn1 setTitle:@"创建JS文件" forState:UIControlStateNormal];
    [self.scrollView addSubview:btn1];
    
    //清除沙盒文件
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.backgroundColor =  [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    btn2.frame = CGRectMake(btnW, 50, btnW, 44);
    [btn2 setTitle:@"清除下载文件" forState:UIControlStateNormal];
    [self.scrollView addSubview:btn2];
    
    //更新压缩包名称，可以更新为含../的文件名
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn3.backgroundColor =  [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    btn3.frame = CGRectMake(btnW*2, 50, btnW, 44);
    [btn3 setTitle:@"自动命名ZIP" forState:UIControlStateNormal];
    [self.scrollView addSubview:btn3];
    
    //从网络下载zip压缩包
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn4.backgroundColor =  [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    btn4.frame = CGRectMake(5, 100, kSW, 44);
    [btn4 setTitle:@"下载zip压缩包" forState:UIControlStateNormal];
    [self.scrollView addSubview:btn4];
    
    //下载成功后展示文件列表
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 150, kSW - 60, 260)];
    textView.text = @"目标：替换jspatch文件夹下热修复文件hot.js;\n1、zip包下载默认路径为当前目录下zip/default文件夹下；\n步骤：\n2、可以点击[创建JS文件]按钮创建jspatch/hot.js文件;\n3、在输入框输入ZIP文件名称模拟替换文件和文件名称;\n4、'../'表示当前目录的上级目录,即当前的父目录;\n;\n5、[清除下载文件]按钮会清除cache文件夹下所有文件;\n6、[自动命名ZIP]按钮模拟将下载的压缩包重命名为../jspatch;\n";
    [self.scrollView addSubview:textView];
    self.cacheListView = textView;
    
    UITextView *jstextView = [[UITextView alloc]initWithFrame:CGRectMake(5, 410, kSW - 60, 100)];
    jstextView.text = @"";
    jstextView.backgroundColor = [UIColor magentaColor];
    [self.scrollView addSubview:jstextView];
    self.jsFileView = jstextView;
    self.scrollView.contentSize = CGSizeMake(0, kSH);
    
    self.createJsFileBtn = btn1;
    self.clearCacheFilesBtn = btn2;
    self.updateUrlBtn = btn3;
    self.downloadBtn = btn4;
}

@end
