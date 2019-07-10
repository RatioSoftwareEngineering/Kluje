# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  account_id :integer
#  token      :string(255)
#  platform   :string(255)
#  deleted_at :boolean
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe Device do
  let(:token) { '<ala ma kota>' }
  let(:normalized_token) { 'alamakota' }

  describe '#normalize_token' do
    it 'Removes spaces and <>' do
      device = create :device, token: token
      expect(device.token).to eq normalized_token
    end
  end

  describe 'account#add_device' do
    let(:account) { create :account }
    let(:account2) { create :account }

    context 'new token' do
      it 'creates a device' do
        account.add_device 'IOS', token
        expect(account.devices.length).to eq 1
        expect(account.devices.first.platform).to eq 'IOS'
        expect(account.devices.first.token).to eq normalized_token
      end
    end

    context 'existing token' do
      context 'same user' do
        it 'returns existing device' do
          create :device, account: account, token: token
          account.reload
          expect(account.devices.length).to eq 1
          expect(account.devices.first.platform).to eq 'IOS'
          expect(account.devices.first.token).to eq normalized_token

          account.add_device 'IOS', token
          expect(account.devices.length).to eq 1
          expect(account.devices.first.platform).to eq 'IOS'
          expect(account.devices.first.token).to eq normalized_token
        end
      end

      context 'different user' do
        it 'modifies the device' do
          device = create :device, account: account, token: token

          device2 = account2.add_device 'IOS', token

          expect(device2).to eq device
          account.reload
          account2.reload

          expect(account.devices.length).to eq 0
          expect(account2.devices.length).to eq 1
          expect(account2.devices.first.platform).to eq 'IOS'
          expect(account2.devices.first.token).to eq normalized_token
        end
      end
    end
  end
end
