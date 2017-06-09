require File.expand_path("test/test_helper")

describe Samlr::Reference do
  before do
    @response  = fixed_saml_response
    @reference = @response.signature.send(:references).first
  end

  describe "#uri" do
    it "should return the normalized URI" do
      assert_equal "samlr123", @reference.uri
    end
  end

  describe "#digest_method" do
    it "should return the digest implementation" do
      assert_equal OpenSSL::Digest::SHA1, @reference.digest_method
    end
  end

  describe "#digest_value" do
    it "should return the verbatim value" do
      assert_equal "05/ZoKG4L2PiMssuD+msQ9BBl9A=", @reference.digest_value
    end
  end

  describe "namespaces" do
    it "should return the inclusive namespaces" do
      assert_equal ["#default", "samlp", "saml", "ds", "xs", "xsi"].sort, @reference.namespaces.sort
    end
  end
end
