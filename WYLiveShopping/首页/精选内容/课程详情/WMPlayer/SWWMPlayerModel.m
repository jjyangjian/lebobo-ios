//
//  SWWMPlayerModel.m
//  
//
//  Created by zhengwenming on 2018/4/26.
//

#import "SWWMPlayerModel.h"

@implementation SWWMPlayerModel
-(void)setPresentationSize:(CGSize)presentationSize{
    _presentationSize = presentationSize;
    if (presentationSize.width/presentationSize.height<1) {
        self.verticalVideo = YES;
    }
}
@end
