require 'test_helper'

require 'querify'

describe Querify do

    # Reset the config before each "it" spec test
    before do
        Querify.reset_config
    end

    it 'is a module' do
        assert_kind_of Module, Querify
    end

    it 'provides a ::config method' do

        assert_respond_to Querify, :config

    end

    it 'provides a ::configure method' do

        assert_respond_to Querify, :configure

    end

    describe "configuring querify" do

        it "initializes with an empty config" do

            assert_kind_of Querify::Config, Querify.config
            assert_nil Querify.config.per_page
            assert_nil Querify.config.min_per_page
            assert_nil Querify.config.max_per_page

        end

        it "can be configured via ::configure" do

            Querify.configure do |config|
                config.per_page = 50
                config.min_per_page = 20
                config.max_per_page = 100
            end

            assert_equal 50, Querify.config.per_page
            assert_equal 20, Querify.config.min_per_page
            assert_equal 100, Querify.config.max_per_page

        end

    end

end
