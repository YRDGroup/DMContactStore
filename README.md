兼容iOS9以前的通讯录操作
#DMContactStore
针对通讯录iOS9以后的兼容问题，提供了解决方案。
##目前支持通讯录所有联系人获取和单个联系人的获取
##针对导航栏的改变问题提供了解决办法。

##功能拆分
  最近贷嘛功能越做越多，复用性太差，将一些可以通用的功能模块进行拆分，便于后期维护。

##开始
支持Pod，或手动导入文件夹DMContactStore
```bash
    pod 'DMContactStore'
```

```objective-c
    #import "DMContactStore.h"
```

##声明
首先，一定要在 interface里面声明对象，如果直接初始化临时的对象，无法进行通讯录的操作。（原因正在查明中...）
```objective-c
@interface ViewController ()
@property (nonatomic, strong) DMContactStore *contactsStore;
@end
```

##获取所有人联系人的信息
```objective-c
- (IBAction)getAll:(id)sender {
    DMContactStore *store = [[DMContactStore alloc]init];
    [store callContactStoreGetAllHandler:^(NSArray *contactStoreModels) {
       
        for (DMContactStoreModel *model in contactStoreModels) {
            NSLog(@"%@",model);
        }
        
    } unAuthorizedBlock:^{
        
    }];
    
}
```
##获取单个联系人的信息，需要4个block进行处理。（详细见Demo）
```objective-c
- (IBAction)getSingle:(id)sender {
    
    self.contactsStore = [[DMContactStore alloc]init];
    [self.contactsStore callContactsHandler:^(DMContactStoreModel *contactStoreModel) {
        
        NSLog(@"%@",contactStoreModel);
        
    } unAuthorizedBlock:nil fitForContactsUtilBlock:nil fitForYourAppBlock:^{
        //和初始化时保持一致,要不然会变成白色navbar
        UINavigationBar *navBar = [UINavigationBar appearance];
        // 1.2.设置导航栏背景
        [navBar setBackgroundImage:[UIImage imageNamed:@"newNarBar"] forBarMetrics:UIBarMetricsDefault];
        // 1.3.设置导航栏的文字
        [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        
    } cancelContactsHandler:^{
        
        NSLog(@"用户取消了选择");
        
    }];
}
```


