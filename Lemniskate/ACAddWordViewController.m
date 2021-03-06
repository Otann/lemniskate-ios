//
//  AddLemniWordViewController.m
//  Lemniskate
//
//  Created by Chebotaev Anton on 09/12/14.
//  Copyright (c) 2014 MonadCompany. All rights reserved.
//

#import "ACAddWordViewController.h"
#import "ACWordForm.h"
#import "ACAppDelegate.h"
#import "LemniWord.h"
#import "LemniCollection.h"

@interface ACAddWordViewController () <MDCPhotoPickerDelegate, MDCTextViewTableViewCellDelegate>
@property (nonatomic, strong) LemniCollection *collection;
@property (nonatomic, strong) LemniWord *word;
@property (nonatomic, strong) ACWordForm *form;
@end

@implementation ACAddWordViewController

#pragma mark - Initialization

- (instancetype)initWithCollection:(LemniCollection *)collection
{
    self = [super init];
    if (self) {
        self.collection = collection;
    }

    return self;
}

+ (instancetype)controllerWithCollection:(LemniCollection *)collection
{
    return [[self alloc] initWithCollection:collection];
}

#pragma mark - Getters

- (NSString *)title
{
    return @"New Word";
}

- (LemniWord *)word
{
    if (!_word) {
        ACAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LemniWord"
                                                  inManagedObjectContext:delegate.managedObjectContext];
        _word = (LemniWord *)[[NSManagedObject alloc] initWithEntity:entity
                                      insertIntoManagedObjectContext:delegate.managedObjectContext];
        _word.collection = self.collection;
    }
    return _word;
}

- (ACWordForm *)form {
    if (!_form) {
        _form = [[ACWordForm alloc] initWithFrame:[self.view bounds]];
        [_form setWord:self.word];
        [_form setPhotoPickerDelegate:self];
        [_form setTextViewDelegate:self];
    }
    return _form;
}


#pragma mark - UIViewController lifecycle

- (void)loadView
{
    [super loadView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelBarButtonItemTap:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(doneBarButtonItemTap:)];
    [self.view addSubview:self.form];
}

#pragma mark - DZNPhotoPickerControllerDelegate

- (void)presentChildViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)hidePhotoPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)initialSearchTerm
{
    return self.form.word.spelling;
}

#pragma mark - MDCTextViewTableViewCellDelegate

- (void)presentTextViewViewController:(ACTextViewViewController *)controller
{
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Action handlers

- (void)cancelBarButtonItemTap:(UIBarButtonItem *)sender
{
    [self.word.managedObjectContext deleteObject:self.word];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneBarButtonItemTap:(UIBarButtonItem *)sender
{
    NSString *name = self.form.word.spelling;
    if ([name length] == 0) {
        return;
    }

    // save word from form
    NSError *error = nil;
    [self.form.word.managedObjectContext save:&error];
    NSLog(@"Saved word, error: %@", error);

    // and pop out
    [self.navigationController popViewControllerAnimated:YES];
}

@end
