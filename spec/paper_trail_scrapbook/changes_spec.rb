# frozen_string_literal: true

require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe Changes do
    let(:version) do
      double(PaperTrail::Version, id: 2_674_798,
                     item_type: 'Widget',
                     item_id: 4804,
                     event: 'update',
                     whodunnit: '1742',
                     object: ['---',
                              'id: ',
                              'amount: ',
                              'authorization_id: ',
                              'paid_on: ',
                              'created_at: ',
                              'updated_at: ',
                              'status: active',
                              'name: ',
                              'email: ',
                              'x_address: ',
                              'notes: ',
                              'internal_notes: ',
                              'discount_percent: !ruby/object:BigDecimal 18:0.0',
                              'order_number: ',
                              'sponsor_delivery_date: ',
                              'other_terms: ',
                              'payment_terms_cd: ',
                              'payment_due_date: ',
                              'other_payment_terms: ',
                              'created_by: ',
                              'sent: false',
                              'token: ',
                              'discounted_amount: '].join("\n"),
                     created_at: Time.current,
                     object_changes: ['---',
                                      'email:',
                                      '- ',
                                      '- tim@redbox.com',
                                      'name:',
                                      '- ',
                                      '- Tim Chambers',
                                      'order_number:',
                                      '- ',
                                      "- ''",
                                      'notes:', '- ', "- ''",
                                      'internal_notes:', '- ', "- ' '",
                                      'other_terms:', "- ' '", '-',
                                      'payment_terms_cd:', '- ', '- 1',
                                      'other_payment_terms:', '- ', "- ' '",
                                      'sent:', '- false', '- true',
                                      'created_by:',
                                      '- ',
                                      '- 1742',
                                      'amount:',
                                      '- ',
                                      '- 29612.0',
                                      'unchanged:',
                                      '- 2',
                                      '- 2',
                                      'discounted_amount:',
                                      '- ',
                                      '- !ruby/object:BigDecimal 36:0.29612E5',
                                      'created_at:',
                                      '- ',
                                      '- &1 2017-06-07 21:37:02.188657104 Z',
                                      'updated_at:',
                                      '- ',
                                      '- *1',
                                      'id:',
                                      '- ',
                                      '- 4806',
                                      'status:',
                                      '- active',
                                      '- issued'].join("\n"))
    end

    let(:version_with_json_col) do
      double(id: 2_674_798,
                     item_type: 'Widget',
                     item_id: 4804,
                     event: 'update',
                     whodunnit: '1742',
                     object: ['---',
                              'id: ',
                              'amount: ',
                              'authorization_id: ',
                              'paid_on: ',
                              'created_at: ',
                              'updated_at: ',
                              'status: active',
                              'name: ',
                              'email: ',
                              'x_address: ',
                              'notes: ',
                              'internal_notes: ',
                              'discount_percent: !ruby/object:BigDecimal 18:0.0',
                              'order_number: ',
                              'sponsor_delivery_date: ',
                              'other_terms: ',
                              'payment_terms_cd: ',
                              'payment_due_date: ',
                              'other_payment_terms: ',
                              'created_by: ',
                              'sent: false',
                              'token: ',
                              'discounted_amount: '].join("\n"),
                     created_at: Time.current,
                     object_changes: {'email': [nil, '- tim@redbox.com'],
                                      'name': [nil, 'Tim Chambers'],
                                      'order_number': "''",
                                      'notes': [nil, "''"],
                                      'internal_notes': ['', "' '"],
                                      'other_terms': [' ', nil],
                                      'payment_terms_cd': [nil, 1],
                                      'other_payment_terms': [nil, "' '"],
                                      'sent': [false, true],
                                      'created_by': [nil, 1742],
                                      'amount':[nil,29612.0],
                                      'unchanged': [2,2],
                                      'discounted_amount': [nil, 0.29612E5],
                                      'created_at': [nil,'2017-06-07 21:37:02.188657104 Z'],
                                      'updated_at': [nil,'*1'],
                                      'id': [nil,4806],
                                      'status': ['active','issued']}.with_indifferent_access)
    end

    shared_examples '#change_log' do
      let(:object) { described_class.new(version) }
      let(:subject) { object.change_log }

      it 'provides a set of update changes' do
        result = subject

        expect(result).to match(/discounted amount: 29612.0 added/)
        expect(result).to match(/• status: active -> issued/)
        expect(result).to match(/other terms:   was \*removed\*/)
      end

      it 'filters out unchanged values' do
        result = subject

        expect(result).not_to match(/• unchanged: 2 -> 2/)
      end

      it 'filters the proper columns' do
        result = subject

        expect(result).not_to match(/created_at:/)
        expect(result).not_to match(/updated_at:/)
        expect(result).not_to match(/id:/)
      end

      it 'provides a set of create changes' do
        expect(version).to receive(:event).and_return('create')

        expect(subject).to match(/discounted amount: 29612.0 added$/)
      end
    end

    context 'with object_changes as json' do
      it_behaves_like '#change_log' do
        let(:version) {version_with_json_col}

        before do
          expect(version).to receive(:class).and_return(PaperTrail::Version)
          expect(PaperTrail::Version).to receive(:object_changes_col_is_json?).and_return(true)
        end
      end
    end

    context 'with object_changes as text' do
      it_behaves_like '#change_log' do
        let(:verson) { version }

        before do
          expect(version).to receive(:class).and_return(PaperTrail::Version)
          expect(PaperTrail::Version).to receive(:object_changes_col_is_json?).and_return(false)
        end
      end
    end
  end
end
