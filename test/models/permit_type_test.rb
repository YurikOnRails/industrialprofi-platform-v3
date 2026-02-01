require 'test_helper'

class PermitTypeTest < ActiveSupport::TestCase
  def setup
    @team = create(:team)
  end

  test 'should be valid with all attributes' do
    permit_type = build(:permit_type, team: @team)
    assert permit_type.valid?
  end

  test 'should require name' do
    permit_type = build(:permit_type, team: @team, name: nil)
    assert_not permit_type.valid?
    assert_includes permit_type.errors[:name], "can't be blank"
  end

  test 'should require validity_months to be positive' do
    permit_type = build(:permit_type, team: @team, validity_months: 0)
    assert_not permit_type.valid?
  end

  test 'should allow nil validity_months' do
    permit_type = build(:permit_type, team: @team, validity_months: nil)
    assert permit_type.valid?
  end

  test 'should require penalty_amount to be non-negative' do
    permit_type = build(:permit_type, team: @team, penalty_amount: -100)
    assert_not permit_type.valid?
  end

  test 'should allow zero penalty_amount' do
    permit_type = build(:permit_type, team: @team, penalty_amount: 0)
    assert permit_type.valid?
  end

  test 'should belong to team' do
    permit_type = create(:permit_type, team: @team)
    assert_equal @team, permit_type.team
  end
end
