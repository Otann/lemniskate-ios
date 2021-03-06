//
// Created by Chebotaev Anton on 09/12/14.
// Copyright (c) 2014 MonadCompany. All rights reserved.
//

#import "NewLemniCollectionForm.h"
#import "LabeledFieldTableViewCell.h"

@interface NewLemniCollectionForm () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) LabeledFieldTableViewCell *nameCell;
@property (nonatomic, strong) LabeledFieldTableViewCell *commentCell;

@end

@implementation NewLemniCollectionForm

#pragma mark - Getters

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
    }
    return _tableView;
}

- (LabeledFieldTableViewCell *)nameCell {
    if (!_nameCell) {
        _nameCell = [[LabeledFieldTableViewCell alloc] initWithFrame:CGRectZero];
        _nameCell.label.text = @"Name";
    }
    return _nameCell;
}

- (LabeledFieldTableViewCell *)commentCell {
    if (!_commentCell) {
        _commentCell = [[LabeledFieldTableViewCell alloc] initWithFrame:CGRectZero];
        _commentCell.label.text = @"Comment";
    }
    return _commentCell;
}

- (NSString *)name {
    return _nameCell.field.text;
}

- (NSString *)comment {
    return _commentCell.field.text;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: return self.nameCell;
        case 1: return self.commentCell;
        default: return nil; // dunno, should app drop dead?
    }
}

@end