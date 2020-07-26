require 'test_helper'

class CompletionReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should not save report to appointment with existing report" do
    report = CompletionReport.new(reportable_type: 'Appointment', reportable_id: 1, assisted_patient_to_eat: true, planning_id: 1, patient_id: 1)

    assert_not report.save, 'Saved a completion report on top of existing report'
  end
end
