//
//  DMContactStore.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "DMContactStore.h"
#import <GJAlertController/GJAlertController.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#else
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#endif

/** 通讯录数据 */
static NSArray *contactsArr;

@interface DMContactStore ()

@property (nonatomic, copy) DMContactStoreGetAllBlock contactsGetAllBlock;
@property (nonatomic, copy) DMContactStoreGetSingleBlock contactsGetSingleBlock;
@property (nonatomic, copy) DMContactStoreCancelBlock cancelBlock;
@property (nonatomic, strong) NSArray *contactModels;
@end

@implementation DMContactStore

- (void)callContactStoreGetAllHandler:(DMContactStoreGetAllBlock)getAllHandler
{
    self.contactsGetAllBlock = getAllHandler;
    [DMContactStore CheckContactAuthorization:^(bool isAuthorized) {
        if (isAuthorized) {
            NSArray *dataArray = [self fetchContactsModelFromSystem];
            getAllHandler(dataArray);
        } else {
            GJAlertController *alertController = [GJAlertController alertControllerWithTitle:@"无法获取通讯录权限" message:@"请在系统的隐私设置中，允许贷嘛访问您的通讯录" preferredStyle:GJAlertControllerStyleAlert];
            //添加action
            [alertController addAction:[GJAlertAction actionWithTitle:@"好的" style:GJAlertActionStyleDefault handler:^(GJAlertAction *alertAction) {
                
            }]];
            //添加action
            [alertController addAction:[GJAlertAction actionWithTitle:@"去设置" style:GJAlertActionStyleDefault handler:^(GJAlertAction *alertAction) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    }];
#else
                    [[UIApplication sharedApplication] openURL:url];

#endif
                    
                }
            }]];
        }
        
    }];
}

- (void)callContactsHandler:(DMContactStoreGetSingleBlock)getSingleHandler
{
    self.contactsGetSingleBlock = getSingleHandler;
    [DMContactStore CheckContactAuthorization:^(bool isAuthorized) {
        
    }];
}

- (void)cancelContactsHandler:(DMContactStoreCancelBlock)cancelHandler
{
    self.cancelBlock = cancelHandler;
}

+(void)CheckContactAuthorization:(void (^)(bool isAuthorized))block
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
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
}
#else
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

#endif

+ (void) initialize{
    contactsArr = [NSArray array];
}

- (NSArray *)fetchContactsModelFromSystem
{
    NSArray *dataArray;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    //创建CNContactStore对象
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
#else
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
#endif
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
