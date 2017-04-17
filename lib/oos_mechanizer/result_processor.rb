module OosMechanizer
  class ResultProcessor
    def self.process_page(results_page)
      offenses = results_page.css('[id="offensesForm:offensesTable"] tbody tr:nth-child(2n+1)')

      return nil if results_page.css('#errorMessages').text =~ /invalid characters detected/i
      return nil if results_page.css('#errorMessages').text =~ /no matching records/i

      return {
        sid: results_page.css('[id="offensesForm:out_SID"]').text,
        name: results_page.css('[id="offensesForm:name"]').text,

        age: results_page.css('[id="offensesForm:age"]').text,
        gender: results_page.css('[id="offensesForm:sex"]').text,
        height: results_page.css('[id="offensesForm:height"]').text,
        weight: results_page.css('[id="offensesForm:weight"]').text,
        dob: results_page.css('[id="offensesForm:dob"]').text,
        race: results_page.css('[id="offensesForm:race"]').text,
        hair: results_page.css('[id="offensesForm:hair"]').text,
        eyes: results_page.css('[id="offensesForm:eyes"]').text,

        caseload_number: results_page.css('[id="offensesForm:caseloadNumber"]').text,
        caseload_name: results_page.css('[id="offensesForm:caseloadMgrsTable"]').text.strip,

        location: results_page.css('[id="offensesForm:locationBlock"] td:nth-child(2)').text,
        status: results_page.css('[id="offensesForm:status"]').text,
        admission_date: results_page.css('[id="offensesForm:admitDate"]').text,
        earliest_release_date: results_page.css('[id="offensesForm:relDate"]').text,

        offenses: offenses.map {|o| o.text.strip.gsub(/\s+/, ',') },
        num_offenses: offenses.length,
      }
    end
  end
end
