Pod::Spec.new do |s|
  s.name             = 'Duvet'
  s.version          = '0.0.6'
  s.summary          = 'A configurable framework for presenting bottom sheets on iOS.'
  s.description      = <<-DESC
    Duvet is a configurable framework for presenting bottom sheets on iOS. It
    makes it easy to create sheets that can either be a fixed size or sized to
    fit the content that you want to display.
                       DESC
  s.homepage         = 'https://github.com/livefront/Duvet'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Matt Czech' => 'matt@livefront.com' }
  s.source           = { :git => 'https://github.com/livefront/Duvet.git', :tag => s.version.to_s }
  s.source_files     = 'Duvet/**/*'
  s.exclude_files    = 'Duvet/**/*.plist'
  s.swift_version    = '5.0'
  s.ios.deployment_target = '11.0'
end
