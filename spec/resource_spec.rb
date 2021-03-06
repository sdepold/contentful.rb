require 'spec_helper'

describe Contentful::Resource do
  it 'must be included to get functionality' do
    c = Class.new
    c.send :include, Contentful::Resource
    expect( c ).to respond_to :property_coercions
  end

  describe 'creation' do
    it 'must be initialized with a (hash) object' do
      expect{
        Contentful::ContentType.new json_fixture('nyancat')
      }.not_to raise_error
    end

    it 'can deal with invalid objects' do
      expect{
        Contentful::ContentType.new({})
      }.not_to raise_error
    end
  end

  describe '#request' do
    it 'will return a request object, if it has been initialized with one' do
      request  = Contentful::Request.new(nil, 'content_types')
      resource = Contentful::ContentType.new({}, request)
      expect( resource.request ).to eq request
    end
  end

  describe '#reload' do
    let(:client){ create_client }
    let(:entry){ vcr('entry'){ client.entry 'nyancat' } }

    it 'triggers the request connected to the resource (again)' do
      stub(entry.request).get
      entry.reload
      expect( entry.request ).to have_received.get
    end

    it 'the reloaded resource is different from the original one' do
      reloaded_entry = vcr('reloaded_entry'){ entry.reload }
      expect( reloaded_entry ).to be_a Contentful::Entry
      expect( reloaded_entry ).not_to be entry
    end

    it 'will return false if #request not available' do
      expect( Contentful::ContentType.new({}).reload ).to be_false
    end
  end
end