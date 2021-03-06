require_relative "../test_helper"

describe Samlr::Tools::LogoutResponseBuilder do
  describe ".build" do
    before do
      @xml = Samlr::Tools::LogoutResponseBuilder.build(
        :issuer => "https://sp.example.com/saml2",
        :name_id => "test@test.com"
      )
      @doc = Nokogiri::XML(@xml) { |c| c.strict }
    end

    it "generates a request document" do
      assert_equal "LogoutResponse", @doc.root.name

      issuer = @doc.root.at("./saml:Issuer", Samlr::NS_MAP)
      assert_equal "https://sp.example.com/saml2", issuer.text
    end

    it "validates against schemas" do
      assert Samlr::Tools.validate(:document => @xml)
    end
  end
end
