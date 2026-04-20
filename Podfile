platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'WYLiveShopping' do
  pod 'AFNetworking','4.0.1'
  pod 'YYWebImage','1.0.5'
  pod 'SDWebImage','5.9.0'
  pod 'FLAnimatedImage','1.0.16'
  #    pod 'SDWebImage/GIF'
  pod 'MJRefresh','3.7.2'
  pod 'Masonry','1.1.0'
  # bugly
  pod 'Bugly', '~> 2.4.6'
  #    #分享
  pod 'mob_sharesdk','4.4.34'#'4.3.8'
  pod 'mob_sharesdk/ShareSDKPlatforms/QQ'
  pod 'mob_sharesdk/ShareSDKPlatforms/WeChatFull'
  pod 'mob_sharesdk/ShareSDKPlatforms/Apple'
  #   支付宝
  pod 'AliPay','15.7.4.2'
#  pod 'OpenSSL-for-iOS', '~> 1.0.2.d.1'
  #  #键盘管理
  pod 'IQKeyboardManager','6.5.5'
  #  轮播图（未使用，已移除）
  #  提示语展示框
  pod 'MBProgressHUD','1.2.0'
  #图片选择器
  pod 'TZImagePickerController','3.6.4'
  #七牛
  pod 'Qiniu','8.3.0'
  #AT 功能
  pod 'HPGrowingTextView','1.1'
  # pod 'MJExtension','3.3.0' # AI检测没用到此第三方
  pod 'EBBannerView','1.1.2'
#  pod 'TXLiteAVSDK_Smart','~> 6.7.7754'
#  pod 'TXLiteAVSDK_Smart','9.1.10564' #'9.1.10566'
#  pod 'TXLiteAVSDK_Smart','11.9.15963' #'9.1.10566'
pod 'TXLiteAVSDK_Professional','11.9.15963'
#  pod 'TXLiteAVSDK_Smart','12.7.19272'
  #    pod 'TXIMSDK_TUIKit_live_iOS'
  pod 'TXIMSDK_Plus_iOS','5.6.1202'
  pod 'Toast','4.0.0'
  pod 'MMLayout','0.2.0'
  pod 'ReactiveObjC','3.1.1'

  pod 'ZFPlayer','4.0.1'
  pod 'ZFPlayer/ControlView'
  pod 'ZFPlayer/ijkplayer'
  pod 'ZFPlayer/AVPlayer'

  # pod 'SSZipArchive','2.2.3' # AI检测没用到此第三方
  pod 'CWStatusBarNotification','2.3.5'
  #SVGAPlayer
  pod 'SVGAPlayer','2.5.7'
  pod 'TYPagerController','2.1.2'
  use_frameworks!
  #socket.io
  pod 'Socket.IO-Client-Swift','15.2.0'

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        end
      end
    end
  end
end
