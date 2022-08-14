# frozen_string_literal: true

require 'spec_helper'

module PaperTrailScrapbook
  ::RSpec.describe Changes do
    let(:version) do
      OpenStruct.new(id: 2_674_798,
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

    let(:object) { described_class.new(version) }
    let(:subject) { object.change_log }

    describe '#change_log' do
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
        version.event = 'create'

        expect(subject).to match(/discounted amount: 29612.0$/)
      end
    end
  end
end
