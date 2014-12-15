//
//  MDCImagePickerTableViewCellDelegate.h
//  Lemniskate
//
//  Created by Chebotaev Anton on 15/12/14.
//  Copyright (c) 2014 MonadCompany. All rights reserved.
//

#import "DZNPhotoPickerController.h"

@protocol MDCImagePickerDelegate <NSObject>
- (void)presentPhotoPicker:(DZNPhotoPickerController *)picker;
- (void)hidePhotoPicker;
@end
