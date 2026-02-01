require 'test_helper'

class WorkerTest < ActiveSupport::TestCase
  def setup
    @team = create(:team)
  end

  test 'should be valid with all attributes' do
    worker = build(:worker, team: @team)
    assert worker.valid?
  end

  test 'should require last_name' do
    worker = build(:worker, team: @team, last_name: nil)
    assert_not worker.valid?
    assert_includes worker.errors[:last_name], "can't be blank"
  end

  test 'should require first_name' do
    worker = build(:worker, team: @team, first_name: nil)
    assert_not worker.valid?
    assert_includes worker.errors[:first_name], "can't be blank"
  end

  test 'should require employee_number' do
    worker = build(:worker, team: @team, employee_number: nil)
    assert_not worker.valid?
    assert_includes worker.errors[:employee_number], "can't be blank"
  end

  test 'should have unique employee_number within team' do
    create(:worker, team: @team, employee_number: 'TN-001')
    worker2 = build(:worker, team: @team, employee_number: 'TN-001')
    assert_not worker2.valid?
    assert_includes worker2.errors[:employee_number], 'has already been taken'
  end

  test 'should allow same employee_number in different teams' do
    team2 = create(:team)
    create(:worker, team: @team, employee_number: 'TN-001')
    worker2 = build(:worker, team: team2, employee_number: 'TN-001')
    assert worker2.valid?
  end

  test 'full_name should return formatted name' do
    worker = build(:worker, last_name: 'Иванов', first_name: 'Иван', middle_name: 'Иванович')
    assert_equal 'Иванов Иван Иванович', worker.full_name
  end

  test 'full_name should handle nil middle_name' do
    worker = build(:worker, last_name: 'Иванов', first_name: 'Иван', middle_name: nil)
    assert_equal 'Иванов Иван', worker.full_name
  end

  test 'should support soft delete' do
    worker = create(:worker, team: @team)
    worker.discard
    assert worker.discarded?
  end

  test 'should not appear in default scope after discard' do
    worker = create(:worker, team: @team)
    worker_id = worker.id
    worker.discard
    assert_nil Worker.find_by(id: worker_id)
  end

  test 'should appear when using unscoped after discard' do
    worker = create(:worker, team: @team)
    worker_id = worker.id
    worker.discard
    assert_not_nil Worker.unscoped.find_by(id: worker_id)
  end

  test 'should belong to team' do
    worker = create(:worker, team: @team)
    assert_equal @team, worker.team
  end

  # Cascade soft-delete tests
  test 'should discard certifications when worker is discarded' do
    permit_type = create(:permit_type, team: @team)
    worker = create(:worker, team: @team)
    cert = create(:certification, worker: worker, permit_type: permit_type)

    worker.discard
    cert.reload

    assert cert.discarded?
  end

  test 'should undiscard certifications when worker is undiscarded' do
    permit_type = create(:permit_type, team: @team)
    worker = create(:worker, team: @team)
    cert = create(:certification, worker: worker, permit_type: permit_type)

    worker.discard
    worker.undiscard
    cert.reload

    assert_not cert.discarded?
  end
end
