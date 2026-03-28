//
//  SWAddAddressVC.m
//  yunbaolive
//
//  Created by IOS1 on 2019/3/20.
//  Copyright © 2019 cat. All rights reserved.
//

#import "SWAddAddressVC.h"
#import "SWMyTextView.h"

@interface SWAddAddressVC ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *cityTextField;
@property (nonatomic, strong) UITextField *addressTextField;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic, strong) UIView *cityPickerBackgroundView;
@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) NSArray *provinceArray;
@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *districtArray;
@property (nonatomic, copy) NSString *provinceString;
@property (nonatomic, copy) NSString *cityString;
@property (nonatomic, copy) NSString *districtString;
@property (nonatomic, copy) NSString *cityID;
@property (nonatomic, strong) NSDictionary *areaDictionary;
@property (nonatomic, copy) NSString *selectedProvince;
@property (nonatomic, strong) UIButton *defaultButton;
@property (nonatomic, strong) NSArray *areaArray;

@end

@implementation SWAddAddressVC

- (void)tapClick {
    [self.phoneTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
}

- (void)textFiledEditChanged:(id)sender {
    if (self.nameTextField.text.length > 0 && self.phoneTextField.text.length > 0 && self.addressTextField.text.length > 0 && self.cityTextField.text.length > 0) {
    } else {
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"添加地址";
    self.view.backgroundColor = colorf0;
    [self creatUI];
}

- (void)creatUI {
    NSArray *array = @[@"姓名", @"联系电话", @"所在地区", @"详细地址"];
    NSArray *placeHolderArray = @[@"请输入姓名", @"请输入联系电话", @"省，市，区", @"请填写具体地址"];
    for (int i = 0; i < array.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(self.view);
            make.top.equalTo(self.naviView.mas_bottom).offset(i * 51 + 5);
            make.height.mas_equalTo(51);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.font = SYS_Font(15);
        label.textColor = color32;
        label.text = array[i];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.top.equalTo(view);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(50);
        }];

        UITextField *textField = [[UITextField alloc] init];
        textField.font = SYS_Font(15);
        textField.textColor = color32;
        textField.placeholder = placeHolderArray[i];
        [view addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(label);
            make.height.equalTo(view).offset(-1);
            make.left.equalTo(label.mas_right).offset(3);
            make.right.equalTo(view).offset(-30);
        }];

        switch (i) {
            case 0:
                self.nameTextField = textField;
                break;
            case 1:
                self.phoneTextField = textField;
                break;
            case 2:
                textField.text = placeHolderArray[i];
                self.cityTextField = textField;
                break;
            case 3:
                self.addressTextField = textField;
                break;
            default:
                break;
        }

        UIView *lineV = [[UIView alloc] init];
        lineV.backgroundColor = colorf0;
        [view addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.right.equalTo(view).offset(-15);
            make.bottom.equalTo(view);
            make.height.mas_equalTo(1);
        }];

        if (i == 2) {
            self.cityTextField.userInteractionEnabled = NO;
            UIImageView *rightImgView = [[UIImageView alloc] init];
            rightImgView.image = [UIImage imageNamed:@"address选地址"];
            rightImgView.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:rightImgView];
            [rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(label);
                make.right.equalTo(view).offset(-10);
                make.width.height.mas_equalTo(15);
            }];
            UIButton *button = [UIButton buttonWithType:0];
            [button addTarget:self action:@selector(selectCityType) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.width.height.equalTo(view);
            }];
        }
    }

    UIView *defaultView = [[UIView alloc] init];
    defaultView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:defaultView];
    [defaultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.view);
        make.top.equalTo(self.naviView.mas_bottom).offset(4 * 51 + 10);
        make.height.mas_equalTo(50);
    }];

    self.defaultButton = [UIButton buttonWithType:0];
    [self.defaultButton setImage:[UIImage imageNamed:@"jubao_nor"] forState:0];
    [self.defaultButton setImage:[UIImage imageNamed:@"cart_sel"] forState:UIControlStateSelected];
    [self.defaultButton setTitle:@"  设置为默认地址" forState:0];
    [self.defaultButton setTitleColor:color32 forState:0];
    self.defaultButton.titleLabel.font = SYS_Font(14);
    [self.defaultButton addTarget:self action:@selector(defaultBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [defaultView addSubview:self.defaultButton];
    [self.defaultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(defaultView).offset(15);
        make.centerY.equalTo(defaultView);
    }];

    if (self.model) {
        self.provinceString = self.model.province;
        self.cityString = self.model.city;
        self.districtString = self.model.area;
        self.cityTextField.text = [NSString stringWithFormat:@"%@%@%@", self.model.province, self.model.city, self.model.area];
        self.nameTextField.text = self.model.name;
        self.phoneTextField.text = self.model.mobile;
        self.addressTextField.text = self.model.detail;
        self.defaultButton.selected = [self.model.isdef intValue];
    }

    UIButton *saveButton = [UIButton buttonWithType:0];
    [saveButton setBackgroundColor:normalColors];
    [saveButton setTitle:@"立即保存" forState:0];
    saveButton.titleLabel.font = SYS_Font(15);
    [saveButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    saveButton.layer.cornerRadius = 20;
    saveButton.layer.masksToBounds = YES;
    [self.view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(defaultView.mas_bottom).offset(15);
        make.width.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(40);
    }];
}

- (void)defaultBtnClick {
    self.defaultButton.selected = !self.defaultButton.selected;
}

- (void)selectCityType {
    [self tapClick];
    if (!self.cityPickerBackgroundView) {
        self.cityPickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        self.cityPickerBackgroundView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
        [self.view addSubview:self.cityPickerBackgroundView];

        UIView *pickBView = [[UIView alloc] initWithFrame:CGRectMake(15, _window_height - 240 - ShowDiff, _window_width - 30, 230)];
        pickBView.layer.cornerRadius = 10;
        pickBView.backgroundColor = [UIColor whiteColor];
        [self.cityPickerBackgroundView addSubview:pickBView];

        UILabel *pickTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(pickBView.width / 2 - 50, 0, 100, 40)];
        pickTitleLabel.textAlignment = NSTextAlignmentCenter;
        pickTitleLabel.text = @"选择地区";
        pickTitleLabel.font = SYS_Font(15);
        pickTitleLabel.textColor = color32;
        [pickBView addSubview:pickTitleLabel];

        UIButton *cancelButton = [UIButton buttonWithType:0];
        cancelButton.frame = CGRectMake(0, 0, 60, 40);
        cancelButton.tag = 100;
        [cancelButton setTitle:@"取消" forState:0];
        [cancelButton setTitleColor:color32 forState:0];
        cancelButton.titleLabel.font = SYS_Font(15);
        [cancelButton addTarget:self action:@selector(cityCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [pickBView addSubview:cancelButton];

        UIButton *sureButton = [UIButton buttonWithType:0];
        sureButton.frame = CGRectMake(pickBView.width - 70, 0, 80, 40);
        sureButton.tag = 101;
        [sureButton setTitle:@"确定" forState:0];
        [sureButton setTitleColor:color32 forState:0];
        sureButton.titleLabel.font = SYS_Font(15);
        [sureButton addTarget:self action:@selector(cityCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [pickBView addSubview:sureButton];

        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 40, pickBView.width, 1) andColor:colorf0 andView:pickBView];

        self.cityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, _window_width, 190)];
        self.cityPicker.backgroundColor = [UIColor clearColor];
        self.cityPicker.delegate = self;
        self.cityPicker.dataSource = self;
        self.cityPicker.showsSelectionIndicator = YES;
        [pickBView addSubview:self.cityPicker];
        [self requestArea];
    } else {
        self.cityPickerBackgroundView.hidden = NO;
    }
}

- (void)cityCancleOrSure:(UIButton *)button {
    if (button.tag != 100) {
        NSInteger provinceIndex = [self.cityPicker selectedRowInComponent:0];
        NSInteger cityIndex = [self.cityPicker selectedRowInComponent:1];
        NSInteger districtIndex = [self.cityPicker selectedRowInComponent:2];
        self.provinceString = minstr([self.provinceArray[provinceIndex] valueForKey:@"n"]);
        self.cityString = minstr([self.cityArray[cityIndex] valueForKey:@"n"]);
        self.cityID = minstr([self.cityArray[cityIndex] valueForKey:@"v"]);
        self.districtString = minstr([self.districtArray[districtIndex] valueForKey:@"n"]);
        self.cityTextField.text = [NSString stringWithFormat:@"%@%@%@", self.provinceString, self.cityString, self.districtString];
    }
    self.cityPickerBackgroundView.hidden = YES;
    [self textFiledEditChanged:nil];
}

- (void)requestArea {
    [SWToolClass getQCloudWithUrl:@"city_list" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.provinceArray = info;
            self.cityArray = [[self.provinceArray firstObject] valueForKey:@"c"];
            self.districtArray = [[self.cityArray firstObject] valueForKey:@"c"];
            [self.cityPicker reloadAllComponents];
        }
    } Fail:^{
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    } else if (component == 1) {
        return self.cityArray.count;
    }
    return self.districtArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return minstr([self.provinceArray[row] valueForKey:@"n"]);
    } else if (component == 1) {
        return minstr([self.cityArray[row] valueForKey:@"n"]);
    }
    return minstr([self.districtArray[row] valueForKey:@"n"]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.cityArray = [self.provinceArray[row] valueForKey:@"c"];
        self.districtArray = [[self.cityArray firstObject] valueForKey:@"c"];
        [self.cityPicker selectRow:0 inComponent:1 animated:YES];
        [self.cityPicker selectRow:0 inComponent:2 animated:YES];
        [self.cityPicker reloadComponent:1];
        [self.cityPicker reloadComponent:2];
    } else if (component == 1) {
        self.districtArray = [self.cityArray[row] valueForKey:@"c"];
        [self.cityPicker selectRow:0 inComponent:2 animated:YES];
        [self.cityPicker reloadComponent:2];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return 80;
    } else if (component == 1) {
        return 100;
    }
    return 115;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width / 3, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    if (component == 0) {
        label.text = minstr([self.provinceArray[row] valueForKey:@"n"]);
    } else if (component == 1) {
        label.text = minstr([self.cityArray[row] valueForKey:@"n"]);
    } else {
        label.text = minstr([self.districtArray[row] valueForKey:@"n"]);
    }
    return label;
}

- (void)rightBtnClick {
    if (self.nameTextField.text.length == 0) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if (self.phoneTextField.text.length == 0) {
        [MBProgressHUD showError:@"请输入联系电话"];
        return;
    }
    if (!self.provinceString || self.provinceString.length == 0) {
        [MBProgressHUD showError:@"请选择所在地区"];
        return;
    }
    if (self.addressTextField.text.length == 0) {
        [MBProgressHUD showError:@"请填写具体地址"];
        return;
    }
    [MBProgressHUD showMessage:@""];
    NSDictionary *dic = @{
        @"is_default": [NSString stringWithFormat:@"%d", self.defaultButton.selected],
        @"id": self.model ? self.model.aID : @"",
        @"real_name": self.nameTextField.text,
        @"phone": self.phoneTextField.text,
        @"address": @{
            @"province": self.provinceString,
            @"city": self.cityString,
            @"district": self.districtString,
            @"city_id": self.model ? @"0" : self.cityID
        },
        @"post_code": @"",
        @"detail": self.addressTextField.text,
        @"type": @"0"
    };
    [SWToolClass postNetworkWithUrl:@"address/edit" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self doReturn];
            });
        }
    } fail:^{
    }];
}

@end
