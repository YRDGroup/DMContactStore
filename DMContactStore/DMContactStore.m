//
//  DMContactStore.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "DMContactStore.h"
#import <GJAlertController/GJAlertController.h>

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "DMCNContactPickerViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DMABPeoplePickerNavigationController.h"

#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define kRootViewController [UIApplication sharedApplication].keyWindow.rootViewController

/** 通讯录数据 */
static NSArray *contactsArr;

@interface DMContactStore ()<
UINavigationControllerDelegate,
CNContactPickerDelegate,
ABPeoplePickerNavigationControllerDelegate
>

@property (nonatomic, copy) DMContactStoreGetAllBlock contactsGetAllBlock;
@property (nonatomic, copy) DMContactStoreGetSingleBlock contactsGetSingleBlock;
@property (nonatomic, copy) DMContactStoreCancelBlock cancelBlock;
@property (nonatomic, copy) DMContactStoreFitForYourAppBlock fitForYourAppBlock;
@property (nonatomic, strong) NSArray *contactModels;
@end

@implementation DMContactStore

- (void)callContactStoreGetAllHandler:(DMContactStoreGetAllBlock)getAllHandler unAuthorizedBlock:(void(^)(void))unAuthorizedBlock
{
    self.contactsGetAllBlock = getAllHandler;
    [DMContactStore CheckContactAuthorization:^(bool isAuthorized) {
        if (isAuthorized) {
            NSArray *dataArray = [self fetchContactsModelFromSystem];
            getAllHandler(dataArray);
        } else {
            if (unAuthorizedBlock) {
                unAuthorizedBlock();
            } else {
                [self showAlertViewForUnAuthorized];
            }
            
        }
        
    }];
}

- (void)callContactsHandler:(DMContactStoreGetSingleBlock)getSingleHandler  unAuthorizedBlock:(void(^)(void))unAuthorizedBlock fitForContactsUtilBlock:(void(^)(void))setFitForContactsUtilBlock fitForYourAppBlock:(DMContactStoreFitForYourAppBlock)fitForYourAppBlock cancelContactsHandler:(DMContactStoreCancelBlock)cancelHandler
{
    self.contactsGetSingleBlock = getSingleHandler;
    self.fitForYourAppBlock = fitForYourAppBlock;
    self.cancelBlock = ^{
        if (fitForYourAppBlock) {
            fitForYourAppBlock();
        }
        cancelHandler();
    };
    [DMContactStore CheckContactAuthorization:^(bool isAuthorized) {
        if (isAuthorized) {
            if (setFitForContactsUtilBlock) {
                setFitForContactsUtilBlock();
            } else {
                [self setFitForContactsUtil];
            }
            if (iOS9Later) {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                //    [CNContactStore authorizationStatusForEntityType:(CNEntityTypeContacts)];
                [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {
                        DMCNContactPickerViewController *picker = [[DMCNContactPickerViewController alloc] init];
                        picker.delegate = self;
                        [kRootViewController presentViewController:picker animated:YES completion:^{}];
                    }
                }];
            } else {
                DMABPeoplePickerNavigationController *peoplePicker = [[DMABPeoplePickerNavigationController alloc] init];
                peoplePicker.peoplePickerDelegate = self;
                [kRootViewController presentViewController:peoplePicker animated:YES completion:nil];
            }

            
            
            
        } else {
            
            if (unAuthorizedBlock) {
                unAuthorizedBlock();
            } else {
                [self showAlertViewForUnAuthorized];
            }
            
        }
        
        
        
        
        
    }];
}

- (void)cancelContactsHandler:(DMContactStoreCancelBlock)cancelHandler
{
    __weak typeof(self) weakSelf = self;
    self.cancelBlock = ^{
        weakSelf.fitForYourAppBlock();
        cancelHandler();
    };
}



#pragma mark - CNContactPickerViewController delegate
// 通讯录列表 - 点击某个联系人 - 详情页 - 点击一个号码, 返回
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    if ([contactProperty.key isEqualToString:@"phoneNumbers"]) {
        NSString *personName = [NSString stringWithFormat:@"%@%@", contactProperty.contact.familyName, contactProperty.contact.givenName];
        NSString *phoneNumber = [contactProperty.value stringValue];
        phoneNumber =  [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        DMContactStoreModel *model = [[DMContactStoreModel alloc]init];
        model.name = personName;
        model.phoneNumber = phoneNumber;
        if (self.contactsGetSingleBlock) {
            self.contactsGetSingleBlock(model);
        }
    } else {
        if (self.contactsGetSingleBlock) {
            self.contactsGetSingleBlock(nil);
        }
    }
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}


#pragma mark - ABPeoplePickerNavigationController delegate
// 在联系人详情页可直接发信息/打电话
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    DMContactStoreModel *model = nil;
    if (index >= 0) {
        CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if (!firstName) {
            firstName = @""; //!!!: 注意这里firstName/lastName是 给@"" 还是 @" ", 如果姓名要求无空格, 则必须为@""
        }
        
        NSString *lastName=(__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (!lastName) {
            lastName = @"";
        }
        
        NSString *personName = [NSString stringWithFormat:@"%@%@", lastName,firstName];
        NSString *phoneNumber = (__bridge NSString*)value;
        phoneNumber =  [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]; // 不然是3-4-4
        model = [[DMContactStoreModel alloc]init];
        model.name = personName;
        model.phoneNumber = phoneNumber;
    }
    if (self.contactsGetSingleBlock) {
        self.contactsGetSingleBlock(model);
    }
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [kRootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}


- (void)showAlertViewForUnAuthorized
{
    GJAlertController *alertController = [GJAlertController alertControllerWithTitle:@"无法获取通讯录权限" message:@"请在系统的隐私设置中，允许贷嘛访问您的通讯录" preferredStyle:GJAlertControllerStyleAlert];
    //添加action
    [alertController addAction:[GJAlertAction actionWithTitle:@"好的" style:GJAlertActionStyleDefault handler:^(GJAlertAction *alertAction) {
        
    }]];
    //添加action
    [alertController addAction:[GJAlertAction actionWithTitle:@"去设置" style:GJAlertActionStyleDefault handler:^(GJAlertAction *alertAction) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
        if(iOS10Later)
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            }];
        else
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }]];
    
    [alertController testShow];
    
}

- (void)setFitForContactsUtil
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 1.2.设置导航栏背景
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}

+(void)CheckContactAuthorization:(void (^)(bool isAuthorized))block
{
    if (iOS9Later) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        CNAuthorizationStatus authStatus  =  [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authStatus != CNAuthorizationStatusAuthorized) {
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(granted);
                });
            }];
            
        } else {
            block(YES);
        }
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        if (authStatus != kABAuthorizationStatusAuthorized) {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(granted);
                });
            });
        } else {
            block(YES);
        }
    }
    
}


+ (void) initialize{
    contactsArr = [NSArray array];
}

- (NSArray *)fetchContactsModelFromSystem
{
    NSArray *dataArray;
    if (iOS9Later) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        //首次访问需用户授权
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            //首次访问通讯录
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_semaphore_signal(sema);
            }];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            contactsArr = [self fetchContactWithContactStore:contactStore];
        }else {
            //非首次访问通讯录
            contactsArr = [self fetchContactWithContactStore:contactStore];
        }
        if (contactsArr) {
            dataArray = contactsArr;
            NSLog(@"contactsArr == %@",contactsArr);
        }
        if (contactsArr) {
            dataArray  = contactsArr;
        }
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        //首次访问需用户授权
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            //首次访问通讯录
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            contactsArr = [self fetchContactWithAddressBook:addressBook];
        }else{
            //非首次访问通讯录
            contactsArr = [self fetchContactWithAddressBook:addressBook];
        }
        if (addressBook) CFRelease(addressBook);
        if (contactsArr) {
            dataArray  = contactsArr;
        }
    }
    return dataArray;
}

- (NSMutableArray *)fetchContactWithContactStore:(CNContactStore *)contactStore{
    //判断访问权限
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized){
        //有权限访问
        NSError *error = nil;
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactOrganizationNameKey];
        //获取通讯录数组
        NSPredicate * predicate = nil;
        NSArray<CNContact*> *arr = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:&error];
        if (!error) {
            NSMutableArray *contacts = [NSMutableArray array];
            for (int i = 0; i < arr.count; i++) {
                DMContactStoreModel *addressBookModel = [[DMContactStoreModel alloc] init];
                CNContact *contact = arr[i];
                //姓名
                NSString *givenName = contact.givenName;
                NSString *familyName = contact.familyName;
                addressBookModel.name = [familyName stringByAppendingString:givenName];
                //电话
                NSString *phoneStr = @"";
                for (CNLabeledValue *labelValue in contact.phoneNumbers) {
                    CNPhoneNumber *phoneNumber = labelValue.value;
                    phoneStr = [phoneStr stringByAppendingString:[NSString stringWithFormat:@"%@;",[self stringByReplaceMobilePhone:phoneNumber.stringValue]]];
                }
                addressBookModel.phoneNumber = phoneStr;
                //公司
                addressBookModel.company = contact.organizationName;
                //邮箱
                NSString *emilStr = @"";
                for (CNLabeledValue *labelValue in contact.emailAddresses) {
                    emilStr = [emilStr stringByAppendingString:[NSString stringWithFormat:@"%@;",labelValue.value]];
                }
                addressBookModel.email = emilStr;
                //地址
                NSString *postalAddress = @"";
                for (CNLabeledValue *labelValue in contact.postalAddresses) {
                    CNPostalAddress *value = labelValue.value;
                    NSString *address = [NSString stringWithFormat:@"%@%@%@%@",value.country,value.state,value.city,value.street];
                    address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    postalAddress = [postalAddress stringByAppendingString:[NSString stringWithFormat:@"%@;",address]];
                }
                addressBookModel.address = postalAddress;
                [contacts addObject:addressBookModel];
            }
            return contacts;
        }else {
            NSDictionary *dic = @{@"contactName":@"",@"contactMobile":@"",@"contactCompany":@"",@"contaceEmail":@"",@"contactAddress":@""};
            NSMutableArray *contacts = [NSMutableArray arrayWithObject:dic];
            return contacts;
        }
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        NSDictionary *dic = @{@"contactName":@"",@"contactMobile":@"",@"contactCompany":@"",@"contaceEmail":@"",@"contactAddress":@""};
        NSMutableArray *contacts = [NSMutableArray arrayWithObject:dic];
        return contacts;
    }
}

- (NSMutableArray *)fetchContactWithAddressBook:(ABAddressBookRef)addressBook{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {//有权限访问
        //获取通讯录中的所有人
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        //通讯录中人数
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray *contacts = [NSMutableArray array];
        //循环，获取每个人的个人信息
        //获取电话号码和email
        for (NSInteger i = 0; i < nPeople; i++) {
            DMContactStoreModel *addressBookModel = [[DMContactStoreModel alloc] init];
            //获取个人
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            //获取个人名字
            CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            CFStringRef abFullName = ABRecordCopyCompositeName(person);
            NSString *nameString = (__bridge NSString *)abName;
            NSString *lastNameString = (__bridge NSString *)abLastName;
            
            if ((__bridge id)abFullName != nil) {
                nameString = (__bridge NSString *)abFullName;
            }else {
                if ((__bridge id)abLastName != nil){
                    nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
                }
            }
            
            addressBookModel.name = nameString;
            if (abLastName) CFRelease(abLastName);
            if (abFullName) CFRelease(abFullName);
            if (abName) CFRelease(abName);
            //公司
            CFTypeRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
            addressBookModel.company =(__bridge NSString *)company;
            if (company) CFRelease(company);
            ABPropertyID multiProperties[] = {
                kABPersonPhoneProperty,
                kABPersonEmailProperty,
                kABPersonAddressProperty,
            };
            NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
            
            //获取手机号、email、地址
            NSString *phoneStr = @"";
            NSString *emailStr = @"";
            NSString *postalAddress = @"";
            
            for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                ABPropertyID property = multiProperties[j];
                ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                NSInteger valuesCount = 0;
                if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
                
                if (valuesCount == 0) {
                    if (valuesRef) CFRelease(valuesRef);
                    continue;
                }
                
                for (NSInteger k = 0; k < valuesCount; k++) {
                    CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                    switch (j) {
                        case 0: {
                            //phoneNumber
                            phoneStr = [phoneStr stringByAppendingString:[NSString stringWithFormat:@"%@;",[self stringByReplaceMobilePhone:(__bridge NSString*)value]]];
                            break;
                        }case 1: {
                            //e-mail
                            emailStr = [emailStr stringByAppendingString:[NSString stringWithFormat:@"%@;",(__bridge NSString*)value]];
                            break;
                        }case 2: {
                            //address
                            NSDictionary *valueDic = (__bridge NSDictionary *)value;
                            NSString *country = [valueDic objectForKey:@"Country"];
                            NSString *state = [valueDic objectForKey:@"State"];
                            NSString *city = [valueDic objectForKey:@"City"];
                            NSString *street = [[valueDic objectForKey:@"Street"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            NSString *address = [NSString stringWithFormat:@"%@%@%@%@",country,state,city,street];
                            postalAddress = [postalAddress stringByAppendingString:[NSString stringWithFormat:@"%@;",address]];
                            break;
                        }
                    }
                    if (value) CFRelease(value);
                }
                if (valuesRef) CFRelease(valuesRef);
            }
            addressBookModel.phoneNumber = phoneStr;
            addressBookModel.email = emailStr;
            addressBookModel.address = postalAddress;
            [contacts addObject:addressBookModel];
        }
        if (allPeople) CFRelease(allPeople);
        return contacts;
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        NSDictionary *dic = @{@"contactName":@"",@"contactMobile":@"",@"contactCompany":@"",@"contaceEmail":@"",@"contactAddress":@""};
        NSMutableArray *contacts = [NSMutableArray arrayWithObject:dic];
        return contacts;
    }
}


- (NSString *)stringByReplaceMobilePhone:(NSString *)mobileNo
{
    mobileNo = [[[[[[[[[[[mobileNo stringByReplacingOccurrencesOfString:@"(" withString:@""]
                         stringByReplacingOccurrencesOfString:@")" withString:@""]
                        stringByReplacingOccurrencesOfString:@" " withString:@""]
                       stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"+86" withString:@""] stringByReplacingOccurrencesOfString:@"17951" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"*86" withString:@""]
                 stringByReplacingOccurrencesOfString:@"*" withString:@""]
                stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    return mobileNo;
}

//lazy load
- (NSArray *)contactModels
{
    if (!_contactModels) {
        _contactModels = [NSArray array];
    }
    return _contactModels;
}

@end
