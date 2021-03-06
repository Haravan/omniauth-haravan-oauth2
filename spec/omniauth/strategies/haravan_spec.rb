require 'spec_helper'
require 'omniauth-haravan-oauth2'
require 'base64'

describe OmniAuth::Strategies::Haravan do
  before :each do
    @request = double('Request',
                      :env => { })
    @request.stub(:params) { {} }
    @request.stub(:cookies) { {} }

    @client_id = '123'
    @client_secret = '53cr3tz'
    @options = {:client_options => {:site => 'https://example.myharavan.com'}}
  end

  subject do
    args = [@client_id, @client_secret, @options].compact
    OmniAuth::Strategies::Haravan.new(nil, *args).tap do |strategy|
      strategy.stub(:request) { @request }
      strategy.stub(:session) { {} }
    end
  end

  describe '#fix_https' do
    it 'replaces http scheme by https' do
      @options = {:client_options => {:site => 'http://foo.bar/'}}
      subject.fix_https
      subject.options[:client_options][:site].should eq('https://foo.bar/')
    end

    it 'does not replace https scheme' do
      @options = {:client_options => {:site => 'https://foo.bar/'}}
      subject.fix_https
      subject.options[:client_options][:site].should eq('https://foo.bar/')
    end
  end

  describe '#client' do
    it 'has correct haravan site' do
      subject.client.site.should eq('https://example.myharavan.com')
    end

    it 'has correct authorize url' do
      subject.client.options[:authorize_url].should eq('/admin/oauth/authorize')
    end

    it 'has correct token url' do
      subject.client.options[:token_url].should eq('/admin/oauth/access_token')
    end
  end

  describe '#callback_url' do
    it "returns value from #callback_url" do
      url = 'http://auth.myapp.com/auth/callback'
      @options = {:callback_url => url}
      subject.callback_url.should eq(url)
    end

    it "defaults to callback" do
      url_base = 'http://auth.request.com'
      @request.stub(:url) { "#{url_base}/page/path" }
      @request.stub(:scheme) { 'http' }
      subject.stub(:script_name) { "" } # to not depend from Rack env
      subject.callback_url.should eq("#{url_base}/auth/haravan/callback")
    end
  end

  describe '#authorize_params' do
    it 'includes default scope for read_products' do
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:scope].should eq('read_products')
    end

    it 'includes custom scope' do
      @options = {:scope => 'write_products'}
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:scope].should eq('write_products')
    end
  end

  describe '#uid' do
    it 'returns the shop' do
      subject.uid.should eq('example.myharavan.com')
    end
  end

  describe '#credentials' do
    before :each do
      @access_token = double('OAuth2::AccessToken')
      @access_token.stub(:token)
      @access_token.stub(:expires?)
      @access_token.stub(:expires_at)
      @access_token.stub(:refresh_token)
      subject.stub(:access_token) { @access_token }
    end

    it 'returns a Hash' do
      subject.credentials.should be_a(Hash)
    end

    it 'returns the token' do
      @access_token.stub(:token) { '123' }
      subject.credentials['token'].should eq('123')
    end

    it 'returns the expiry status' do
      @access_token.stub(:expires?) { true }
      subject.credentials['expires'].should eq(true)

      @access_token.stub(:expires?) { false }
      subject.credentials['expires'].should eq(false)
    end

  end

  describe '#valid_site?' do
    it 'returns true if the site contains .myharavan.com' do
      @options = {:client_options => {:site => 'http://foo.myharavan.com/'}}
      subject.valid_site?.should eq(true)
    end

    it 'returns false if the site does not contain .myharavan.com' do
      @options = {:client_options => {:site => 'http://foo.example.com/'}}
      subject.valid_site?.should eq(false)
    end

    it 'uses configurable option for myharavan_domain' do
      @options = {:client_options => {:site => 'http://foo.example.com/'}, :myharavan_domain => 'example.com'}
      subject.valid_site?.should eq(true)
    end

    it 'allows custom port for myharavan_domain' do
      @options = {:client_options => {:site => 'http://foo.example.com:3456/'}, :myharavan_domain => 'example.com:3456'}
      subject.valid_site?.should eq(true)
    end
  end
end
