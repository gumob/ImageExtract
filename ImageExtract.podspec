Pod::Spec.new do |s|

    s.name      = "ImageExtract"
    s.version   = "1.0.0"
    s.summary   = "A Swift library to allows you to extract the size of an image without downloading."
    s.homepage  = "https://github.com/gumob/ImageExtract"
    s.license   = { :type => "MIT", :file => "LICENSE" }
    s.author    = { "gumob" => "hello@gumob.com" }

    s.requires_arc              = true
    s.source                    = { :git => "https://github.com/gumob/ImageExtract.git", :tag => "#{s.version}", :submodules => true }
    s.source_files              = ["Source/*.{swift}"]
    # s.public_header_files      = "Source/ImageExtract.h"
    # s.private_header_files     = "Module/CWebP/CWebP-umbrella.h"
    # s.preserve_paths           = 'Module/CWebP/module.modulemap'
    # s.module_map               = 'Module/CWebP/module.modulemap'

    ios_deployment_target       = "9.0"
    tvos_deployment_target      = "10.0"
    watchos_deployment_target   = "3.0"
    osx_deployment_target       = "10.11"

    s.ios.deployment_target     = ios_deployment_target
    s.tvos.deployment_target    = tvos_deployment_target
    s.watchos.deployment_target = watchos_deployment_target
    s.osx.deployment_target     = osx_deployment_target
    s.swift_version             = '4.2'

    s.subspec "CWebP" do |webp|
        webp.ios.deployment_target  = ios_deployment_target
        webp.tvos.deployment_target = tvos_deployment_target
        s.watchos.deployment_target = watchos_deployment_target
        webp.osx.deployment_target  = osx_deployment_target
        # webp.preserve_paths         = 'Submodule/libwebp'
        # webp.source_files           = 'Submodule/libwebp/src/**/*.{h,c}'
        # webp.public_header_files    = ["Submodule/libwebp/src/webp/decode.h", "Submodule/libwebp/src/webp/encode.h", "Submodule/libwebp/src/webp/types.h"]
        webp.xcconfig = {
            # 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) IE_WEBP=1',
            'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/Submodule/libwebp/src'
        }
        webp.dependency "libwebp"
    end

    s.default_subspecs = "CWebP"
end
