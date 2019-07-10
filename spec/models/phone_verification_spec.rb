# == Schema Information
#
# Table name: phone_verifications
#
#  id                           :integer          not null, primary key
#  account_id                   :integer
#  mobile_number                :string(255)
#  verification_code            :string(255)
#  verification_code_expires_at :datetime
#  ip                           :string(255)
#  verified                     :boolean
#  created_at                   :datetime
#  updated_at                   :datetime
#

require 'rails_helper'

describe PhoneVerification do
  subject { create :phone_verification }

  describe 'hooks' do
    it 'populates necessary fields' do
      expect(subject.verification_code).to_not be_nil
      expect(subject.verification_code_expires_at).to be <= Time.zone.now + 10.minutes
      expect(subject.verification_code_expires_at).to be > Time.zone.now + 9.minutes
      expect(subject.verified?).to eq false
    end
  end

  describe '#generate_verification_code' do
    it 'creates random code' do
      obj = create :phone_verification
      expect(obj.verification_code).to_not eq subject.verification_code
    end
  end

  describe '#verify_code' do
    context 'correct code' do
      it 'returns true and sets verified' do
        expect(subject.verify_code(subject.verification_code)).to be true
        expect(subject.verified?).to be true
        expect(subject.verification_code_expires_at).to be <= Time.zone.now
      end
    end

    context 'incorrect code' do
      it 'returns false' do
        incorrect_code = (subject.verification_code.to_i + 1).to_s
        expect(subject.verify_code(incorrect_code)).to be false
        expect(subject.verified?).to be false
        expect(subject.verification_code_expires_at).to be > Time.zone.now
      end
    end

    context 'code expired' do
      it 'returns false' do
        subject.update_attributes(verification_code_expires_at: Time.zone.now - 1.second)
        expect(subject.verify_code(subject.verification_code)).to be false
        expect(subject.verified?).to be false
        expect(subject.verification_code_expires_at).to be < Time.zone.now
      end
    end
  end
end
