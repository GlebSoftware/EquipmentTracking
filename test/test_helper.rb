# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

# raise localisation exception
# Used to find missing translation fields.
# http://dev.innovationfactory.nl/2009/05/04/rails-i18n-caveats-and-tips/
module I18n
  def self.just_raise(*args)
    raise args.first
  end
end
I18n.exception_handler = :just_raise
