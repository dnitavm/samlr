require File.expand_path("test/test_helper")

def condition(before, after)
  element = Nokogiri::XML::Element.new('saml:Condition', Nokogiri::XML(''))
  element["NotBefore"] = before.utc.iso8601 if before
  element["NotOnOrAfter"] = after.utc.iso8601 if after

  Samlr::Condition.new(element, {})
end

describe Samlr::Condition do
  before do
    @not_before = (Time.now - 10*60)
    @not_after  = (Time.now + 10*60)
  end

  describe "verify!" do
    describe "audience verification" do
      let(:response) { fixed_saml_response }
      subject { response.assertion.conditions }

      describe "when it is wrong" do
        before do
          response.options[:audience] = 'example.com'
        end

        it "raises an exception" do
          Time.stub(:now, Time.at(1344379365)) do
            assert subject.not_on_or_after_satisfied?
            assert subject.not_before_satisfied?
            refute subject.audience_satisfied?

            begin
              subject.verify!
              flunk "Expected exception"
            rescue Samlr::ConditionsError => e
              assert_match /Audience/, e.message
            end
          end
        end
      end

      describe "when it is right" do
        before do
          response.options[:audience] = 'example.org'
        end

        it "does not raise an exception" do
          Time.stub(:now, Time.at(1344379365)) do
            assert subject.verify!
          end
        end
      end

      describe "using a regex" do
        before do
          response.options[:audience] = /example\.(org|com)/
        end

        it "does not raise an exception" do
          Time.stub(:now, Time.at(1344379365)) do
            assert subject.verify!
          end
        end
      end
    end

    describe "when the lower time has not been met" do
      before  { @not_before = (Time.now + 5*60) }
      subject { condition(@not_before, @not_after) }

      it "raises an exception" do
        assert subject.not_on_or_after_satisfied?
        refute subject.not_before_satisfied?

        begin
          subject.verify!
          flunk "Expected exception"
        rescue Samlr::ConditionsError => e
          assert_match /Not before/, e.message
        end
      end
    end

    describe "when the upper time has been exceeded" do
      before { @not_after = (Time.now - 5*60) }
      subject { condition(@not_before, @not_after) }

      it "raises an exception" do
        refute subject.not_on_or_after_satisfied?
        assert subject.not_before_satisfied?

        begin
          subject.verify!
          flunk "Expected exception"
        rescue Samlr::ConditionsError => e
          assert_match /Not on or after/, e.message
        end
      end
    end

    describe "when no time boundary has been exeeded" do
      subject { condition(@not_before, @not_after) }

      it "returns true" do
        assert subject.verify!
      end
    end
  end

  describe "#audience_satisfied?" do
    it "returns true when audience is a nil value" do
      element = Nokogiri::XML::Node.new('saml:Condition', Nokogiri::XML(''))
      assert Samlr::Condition.new(element, {}).audience_satisfied?
    end

    it "returns true when passed a nil audience" do
      condition = fixed_saml_response.assertion.conditions
      assert_equal 'example.org', condition.audience
      assert condition.audience_satisfied?
    end
  end

  describe "#not_before_satisfied?" do
    it "returns true when passed a nil value" do
      element = Nokogiri::XML::Node.new('saml:Condition', Nokogiri::XML(''))
      assert Samlr::Condition.new(element, {}).not_before_satisfied?
    end
  end

  describe "#not_on_or_after_satisfied?" do
    it "returns true when passed a nil value" do
      element = Nokogiri::XML::Node.new('saml:Condition', Nokogiri::XML(''))
      assert Samlr::Condition.new(element, {}).not_on_or_after_satisfied?
    end
  end
end
