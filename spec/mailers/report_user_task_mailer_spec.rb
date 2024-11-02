require 'spec_helper'

I18n.locale = 'de'

describe ReportUserTaskMailer do

  describe 'registration confirmation' do
    let(:user) { FactoryGirl.create(:user) }
    let(:user_task) { FactoryGirl.create(:user_task_verified) }
    
    subject  { ReportUserTaskMailer.report_task user_task, user }
  
    it 'has correct subject' do
      should have_subject(/Beweis melden/)
    end
  
    it 'has message for link' do
      should have_body_text(/Beweis anzeigen/)
    end

    it 'has a link to reporter' do
      should have_body_text(/Benutzer anzeigen/)
    end
  
  end

  
end