require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe Chapter do
    let(:version) do
      OpenStruct.new(id:             2_674_798,
                     item_type:      'Widget',
                     item_id:        4806,
                     event:          'update',
                     version_author: '1742',
                     object:         "---\nid: \nadvertiser_id: \ncampaign_id: \namount: \nauthorization_id: \npaid_on: \ncreated_at: \nupdated_at: \nstatus: active\nname: \nemail: \nx_address: \nnotes: \ninternal_notes: \ndiscount_percent: !ruby/object:BigDecimal 18:0.0\norder_number: \nsponsor_delivery_date: \nother_terms: \npayment_terms_cd: \npayment_due_date: \nother_payment_terms: \ncreated_by: \nsent: false\nad_agency_id: \ntoken: \ndiscounted_amount: \n",
                     created_at:     Time.now,
                     object_changes: "---\nemail:\n- \n- tim@redbox.com\nname:\n- \n- Tim Chambers\norder_number:\n- \n- ''\nnotes:\n- \n- ''\ninternal_notes:\n- \n- ''\nother_terms:\n- \n- ''\npayment_terms_cd:\n- \n- 1\nother_payment_terms:\n- \n- ''\nsent:\n- false\n- true\ncreated_by:\n- \n- 1742\nadvertiser_id:\n- \n- 3113\namount:\n- \n- 29612.0\ndiscounted_amount:\n- \n- !ruby/object:BigDecimal 36:0.29612E5\ncreated_at:\n- \n- &1 2017-06-07 21:37:02.188657104 Z\nupdated_at:\n- \n- *1\nid:\n- \n- 4806\nstatus:\n- active\n- issued\n")
    end

    let(:object) { described_class.new(version) }
    let(:subject) { object.story }

    describe '#story' do
      it 'provides a whole story' do
        expect(subject).to match(/discounted_amount: 29612.0 added/)
      end
    end
  end
end
