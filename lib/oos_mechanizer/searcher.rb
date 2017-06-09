module OosMechanizer
  class Searcher
    class TooManyResultsError < OosMechanizer::Error; end
    class NoPaginationError < OosMechanizer::Error; end
    class ResponseCodeError < OosMechanizer::Error; end
    class ConnectionFailed < OosMechanizer::Error; end
    class SearchResultError < OosMechanizer::Error; end

    def initialize
      @mech = Mechanize.new do |agent|
        agent.open_timeout = 5
        agent.read_timeout = 5
      end

      @mech.get('http://docpub.state.or.us/OOS/intro.jsf') do |page|
        @search_page = @mech.click 'I Agree'
      end
    rescue Net::HTTP::Persistent::Error
      raise ConnectionFailed.new('Error connecting to OOS')
    end

    def each_result(**kwargs, &block)
      return to_enum(:each_result, **kwargs) unless block_given?

      first_name = kwargs.fetch(:first_name, nil)
      middle_name = kwargs.fetch(:middle_name, nil)
      last_name = kwargs.fetch(:last_name, nil)

      results_page = @search_page.form_with(id: 'mainBodyForm') do |f|
        f['mainBodyForm:FirstName'] = "#{first_name}*" if first_name
        f['mainBodyForm:MiddleName'] = "#{middle_name}*" if middle_name
        f['mainBodyForm:LastName'] = "#{last_name}*" if last_name
      end.click_button

      if (error_message = results_page.css('.errorMessage').text.strip) && error_message.length
        raise SearchResultError.new("OOS returned error: #{error_message}")
      elsif results_page.css('.infoMessage').text =~ /Too many/
        raise TooManyResultsError
      elsif results_page.css('.infoMessage').text =~ /No matching/
        # do nothing
      elsif results_page.css('#offensesForm')
        # if there is one result, click back to the table view
        back_button = results_page.forms.first.button_with(value: 'Back')
        results_page = results_page.forms.first.submit(back_button)

        process_results(results_page, &block)
      else
        process_results(results_page, &block)
      end
    rescue Mechanize::ResponseCodeError
      raise OosMechanizer::Searcher::ResponseCodeError
    rescue Net::HTTP::Persistent::Error
      raise ConnectionFailed.new('Error connecting to OOS')
    end

    def offender_details(sid)
      results_page = @search_page.form_with(id: 'mainBodyForm') do |f|
        f['mainBodyForm:SidNumber'] = sid
      end.click_button

      OosMechanizer::ResultProcessor.process_page(results_page)
    end

    private

    def process_results(results_page)
      pagination = results_page.xpath('//*[@id="mainBodyForm:pageMsg"]').text().match(/Page (\d)\/(\d)/)
      results_page.css('.foundOffenders tbody tr').each do |row|
        yield({
          sid: row.css('td:nth-child(1)').text,
          first: row.css('td:nth-child(2)').text,
          middle: row.css('td:nth-child(3)').text,
          last: row.css('td:nth-child(4)').text,
          dob: row.css('td:nth-child(5)').text,
        })
      end

      if !pagination
        raise NoPaginationError
      end

      (pagination[2].to_i - pagination[1].to_i).times do
        results_page = results_page.forms.first.tap do |f|
          f['mainBodyForm:j_id30.x'] = '1'
          f['mainBodyForm:j_id30.y'] = '1'
        end.submit

        results_page.css('.foundOffenders tbody tr').each do |row|
          yield({
            sid: row.css('td:nth-child(1)').text,
            first: row.css('td:nth-child(2)').text,
            middle: row.css('td:nth-child(3)').text,
            last: row.css('td:nth-child(4)').text,
            dob: row.css('td:nth-child(5)').text,
          })
        end
      end
    end
  end
end
