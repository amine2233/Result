Pod::Spec.new do |s|
		s.name 				= "ResultKit"
		s.version 			= "2.3.0"
		s.summary         	= "Sort description of 'Result' framework"
	    s.homepage        	= "https://github.com/amine2233/Result"
	    s.license           = { type: 'MIT', file: 'LICENSE' }
	    s.author            = { 'Amine Bensalah' => 'amine.bensalah@outlook.com' }
	    s.ios.deployment_target = '10.0'
	    s.osx.deployment_target = '10.12'
	    s.tvos.deployment_target = '10.0'
	    s.watchos.deployment_target = '4.0'
	    s.requires_arc = true
	    s.source            = { :git => "https://github.com/amine2233/Result.git", :tag => s.version.to_s }
	    s.source_files      = "Sources/**/*.swift"
	    s.pod_target_xcconfig = {
    		'SWIFT_VERSION' => '4.2'
  		}
  		s.swift_version = '4.2'
  		s.module_name = "Result"
	end
