Pod::Spec.new do |s|
  s.name         = "DMContactStore"
  s.version      = "1.0.1"
  s.summary      = "兼容iOS9以前的通讯录操作"
  s.description  = <<-DESC
                        通讯录授权、导航栈navbar颜色处理、所有联系人获取、单个联系人获取
                   DESC
  s.homepage     = "https://github.com/YRDGroup/DMContactStore"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Agoer" => "https://github.com/Agoer" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/YRDGroup/DMContactStore.git",  :branch => "master", :tag => "1.0.1" }
  s.source_files  = "DMContactStore", "DMContactStore/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "GJAlertController"
end
