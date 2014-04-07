require 'spec_helper'
require 'refinery/seeds/ext'


describe String do
  it "converts naturally-spaced strings to underscored path segments" do
    "This is a String".underscored_word.should == "this_is_a_string"
    "ThatIsAString".underscored_word.should == "that_is_a_string" # yeah
    "BlahBlahHTTPBlah".underscored_word.should == "blah_blah_http_blah"
    "a-sluggish-string".underscored_word.should == "a_sluggish_string"
    "A MixedForm-string".underscored_word.should == "a_mixed_form_string"
    "a string with é in it".underscored_word.should == "a_string_with_e_in_it"
    "日本語 hello".underscored_word.should == "???_hello"
  end
end
