require 'test_helper'

class CertificationTest < ActiveSupport::TestCase
  def setup
    @team = create(:team)
    @permit_type = create(:permit_type, team: @team, validity_months: 12)
    @worker = create(:worker, team: @team)
  end

  test 'should be valid with all attributes' do
    cert = build(:certification, worker: @worker, permit_type: @permit_type)
    assert cert.valid?
  end

  test 'should require issued_at' do
    cert = build(:certification, worker: @worker, permit_type: @permit_type, issued_at: nil,
                                 expires_at: Date.current + 1.year)
    assert_not cert.valid?
    assert_includes cert.errors[:issued_at], "can't be blank"
  end

  test 'should auto-calculate expires_at from permit_type validity_months' do
    cert = build(:certification, worker: @worker, permit_type: @permit_type,
                                 issued_at: Date.new(2024, 1, 15), expires_at: nil)
    cert.valid?
    assert_equal Date.new(2025, 1, 15), cert.expires_at
  end

  test 'should not override manually set expires_at' do
    cert = build(:certification, worker: @worker, permit_type: @permit_type,
                                 issued_at: Date.new(2024, 1, 15), expires_at: Date.new(2024, 6, 30))
    cert.valid?
    assert_equal Date.new(2024, 6, 30), cert.expires_at
  end

  test 'days_until_expiry should return correct positive value' do
    cert = build(:certification, expires_at: Date.current + 10.days)
    assert_equal 10, cert.days_until_expiry
  end

  test 'days_until_expiry should return correct negative value for expired' do
    cert = build(:certification, expires_at: Date.current - 5.days)
    assert_equal(-5, cert.days_until_expiry)
  end

  test 'days_until_expiry should return nil when expires_at is nil' do
    cert = build(:certification, expires_at: nil)
    assert_nil cert.days_until_expiry
  end

  test 'status should be :expired when past due' do
    cert = build(:certification, expires_at: Date.current - 1.day)
    assert_equal :expired, cert.status
  end

  test 'status should be :critical within 7 days' do
    cert = build(:certification, expires_at: Date.current + 5.days)
    assert_equal :critical, cert.status
  end

  test 'status should be :attention within 30 days' do
    cert = build(:certification, expires_at: Date.current + 20.days)
    assert_equal :attention, cert.status
  end

  test 'status should be :valid after 30 days' do
    cert = build(:certification, expires_at: Date.current + 60.days)
    assert_equal :valid, cert.status
  end

  test 'valid_permit_types should return team permit types' do
    cert = build(:certification, worker: @worker)
    assert_includes cert.valid_permit_types, @permit_type
  end

  test 'expired scope should include expired certifications' do
    expired = create(:certification, worker: @worker, permit_type: @permit_type,
                                     issued_at: Date.current - 2.years, expires_at: Date.current - 1.day)
    valid_cert = create(:certification, worker: @worker,
                                        permit_type: create(:permit_type, team: @team),
                                        expires_at: Date.current + 60.days)

    assert_includes Certification.expired, expired
    assert_not_includes Certification.expired, valid_cert
  end

  test 'critical scope should include certifications expiring within 7 days' do
    critical = create(:certification, worker: @worker, permit_type: @permit_type,
                                      issued_at: Date.current - 1.year, expires_at: Date.current + 5.days)
    valid_cert = create(:certification, worker: @worker,
                                        permit_type: create(:permit_type, team: @team),
                                        expires_at: Date.current + 60.days)

    assert_includes Certification.critical, critical
    assert_not_includes Certification.critical, valid_cert
  end

  test 'attention scope should include certifications expiring within 30 days' do
    attention = create(:certification, worker: @worker, permit_type: @permit_type,
                                       issued_at: Date.current - 1.year, expires_at: Date.current + 20.days)
    valid_cert = create(:certification, worker: @worker,
                                        permit_type: create(:permit_type, team: @team),
                                        expires_at: Date.current + 60.days)

    assert_includes Certification.attention, attention
    assert_not_includes Certification.attention, valid_cert
  end

  test 'should support soft delete' do
    cert = create(:certification, worker: @worker, permit_type: @permit_type)
    cert.discard
    assert cert.discarded?
  end

  test 'should not appear in default scope after discard' do
    cert = create(:certification, worker: @worker, permit_type: @permit_type)
    cert_id = cert.id
    cert.discard
    assert_nil Certification.find_by(id: cert_id)
  end

  test 'should appear when using unscoped after discard' do
    cert = create(:certification, worker: @worker, permit_type: @permit_type)
    cert_id = cert.id
    cert.discard
    assert_not_nil Certification.unscoped.find_by(id: cert_id)
  end
end
