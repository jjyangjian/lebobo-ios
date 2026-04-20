#import "SWLiwuModel.h"
#import "UIImageView+WebCache.h"
@implementation SWLiwuModel
-(instancetype)initWithDictionary:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.imagePath = [map valueForKey:@"icon"];
        self.price = [map valueForKey:@"coin"];
        self.num = [NSString stringWithFormat:@"%@",[map valueForKey:@"nums"]];
        self.type = minstr([map valueForKey:@"type"]);
        self.giftname = minstr([map valueForKey:@"name"]);
        self.ID = minstr([map valueForKey:@"id"]);
        self.mark =minstr([map valueForKey:@"mark"]) ;
        self.duihaiOK = 0;
        
//        [self setView];
    }
    return self;
}
-(void)setView{
    
    CGFloat  H =( _window_height/3- _window_height/18)/2 - 30;
    //_imageVR = CGRectMake(20,5,_window_width/10,_window_width/10);
    
    _imageVR = CGRectMake(0,0,_window_width/4,H);
    
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize  size1 = [_price boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    _priceR = CGRectMake(0,H+15,_window_width/4,20);
    _countR = CGRectMake(0,H,_window_width/4,20);
    CGSize  size2 = [_num boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    _numR = CGRectMake(_imageVR.size.width/2,_imageVR.size.height + size1.height+10, size2.width, size2.height);
}
+(instancetype)modelWithDictionary:(NSDictionary *)map{
    return  [[self alloc]initWithDictionary:map];
}
@end
