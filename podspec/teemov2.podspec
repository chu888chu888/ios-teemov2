
Pod::Spec.new do |s|

  s.name         = "teemov2"
  s.version      = "0.0.1"
  s.summary      = "TeemoV2 - The iOS framework that grows your app fast"

  s.description  = <<-DESC
                   TeemoV2 - The iOS framework that grows your app fast （此开发框架由多玩游戏负责维护，提供邮件级技术支持）
                   Teemo:Teemo, a short-legged animals, escape fast, favorite mushroom, well known as "Group fights can lose, Teemo must die!".
                   Teemo:提莫，一种短腿动物，逃跑超快，最爱蘑菇，素有“团战可以输，提莫必须死！”的美称
                   DESC

  s.homepage     = "https://github.com/duowan/teemov2"

  s.license      = "MIT"

  s.platform     = :ios, "6.0"

  s.author             = { "PonyCui" => "cuis@vip.qq.com" }

  s.default_subspec = "Core"

  s.source       = { :git => "https://github.com/duowan/teemov2.git", :tag => "0.0.1" }

  s.requires_arc = true

  s.subspec "Core" do |ss|
    ss.platform     = :ios, "5.0"
    ss.source_files = "TeemoFramework", "TeemoFramework/**/*.{h,m}"
    ss.preserve_paths = "TeemoFramework/**/*.{php}"
    ss.dependency "gtm-http-fetcher", "~> 1.0.129"
    ss.dependency "Reachability", "~> 3.1.1"
    ss.dependency "MBProgressHUD", "~> 0.8"
    ss.dependency "Objective-LevelDB", "~> 2.0.6"
  end

  s.subspec 'TMOFMDB' do |ss|
    ss.platform     = :ios, "5.0"
    ss.source_files = "TeemoSubmodule/TMOFMDB/*.{h,m}"
    ss.dependency "FMDB", "~> 2.2"
  end

  s.subspec 'TMOSmarty' do |ss|
    ss.platform     = :ios, "5.0"
    ss.source_files = "TeemoSubmodule/TMOSmarty/*.{h,m}"
    ss.dependency "teemov2/Core"
  end

  s.subspec 'TMOTextKit' do |ss|
    ss.platform = :ios, "6.0"
    ss.source_files = "TeemoSubmodule/TMOAttributedLabel/*.{h,m}"
    ss.dependency "NimbusKit-AttributedLabel"
    ss.dependency "teemov2/Core"
  end
  
  s.subspec 'TMOSecurity' do |ss|
    ss.platform     = :ios, "5.0"
    ss.source_files = "TeemoSubmodule/TMOSecurity/*.{h,m}"
    ss.dependency "teemov2/Core"
    ss.dependency "SSKeychain"
    ss.dependency "RNCryptor", "~> 2.2"
  end



end
