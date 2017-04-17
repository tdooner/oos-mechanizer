require 'spec_helper'

RSpec.describe OosMechanizer::ResultProcessor do
  def mechanize_page(fixture = nil)
    fixture_path = File.expand_path(File.join('..', '..', 'spec', 'fixtures', fixture), __FILE__) if fixture
    Mechanize::Page.new(
      URI('http://example.com/'),
      nil,
      fixture ? File.read(fixture_path) : '<html></html>',
      200,
      Mechanize.new
    )
  end

  subject { described_class.process_page(result_page) }

  describe 'with an unknown location' do
    let(:result_page) { mechanize_page('offender_with_no_location.html') }

    it 'gives back the expected location' do
      expect(subject).to include(location: /Marion County/)
    end
  end
end
