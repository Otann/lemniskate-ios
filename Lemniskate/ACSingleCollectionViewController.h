//
//  OneLemniCollectionViewController.h
//  Lemniskate
//
//  Created by Chebotaev Anton on 30/11/14.
//  Copyright (c) 2014 MonadCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LemniCollection.h"

@interface ACSingleCollectionViewController : UIViewController <UITableViewDataSource,
                                                                 UITableViewDelegate,
                                                                 NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) LemniCollection *collection;

@end
