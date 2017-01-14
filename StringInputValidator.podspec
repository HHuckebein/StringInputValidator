

Pod::Spec.new do |s|
  s.name             = 'StringInputValidator'
  s.version          = '0.1.0'
  s.summary          = 'StringInputValidator helps you validating Strings e.g. length, contained characters etc..'

  s.description      = <<-DESC
  A StringInputValidator can be a simple NotEmptyValidator or a CompositeValidator consisting of a LengthValidator
  and e.g. RegularExpressionValidator.numeric. Validation returns a ValidationResult which might be .valid
  or .invalid where the associated value is an OptionSet of type ValidatorError.
                       DESC

  s.homepage         = 'https://github.com/HHuckebein/StringInputValidator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RABE_IT Services' => 'info@berndrabe.de' }
  s.source           = { :git => 'https://github.com/HHuckebein/StringInputValidator.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '10.1'

  s.source_files = '/Sources/**/*'
end
