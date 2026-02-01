class Certification < ApplicationRecord
  include Discard::Model

  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :worker
  belongs_to :permit_type
  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  has_one :team, through: :worker
  # 🚅 add has_one associations above.

  # Scopes
  default_scope -> { kept } # Exclude discarded by default
  scope :expired, -> { where('expires_at < ?', Date.current) }
  scope :critical, -> { where('expires_at >= ? AND expires_at <= ?', Date.current, Date.current + 7.days) }
  scope :attention, -> { where('expires_at > ? AND expires_at <= ?', Date.current + 7.days, Date.current + 30.days) }
  scope :expiring_soon, ->(days) { where('expires_at <= ?', Date.current + days.days) }
  # 🚅 add scopes above.

  # Validations
  validates :permit_type, scope: true
  validates :issued_at, presence: true
  # 🚅 add validations above.

  # Callbacks
  before_validation :set_expires_at_from_permit_type
  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # Required by super_select for permit_type_id
  def valid_permit_types
    team.permit_types
  end

  # Methods
  def days_until_expiry
    return nil unless expires_at

    (expires_at - Date.current).to_i
  end

  def status
    return :expired if expires_at.nil? || expires_at < Date.current
    return :critical if expires_at <= Date.current + 7.days
    return :attention if expires_at <= Date.current + 30.days

    :valid
  end

  private

  def set_expires_at_from_permit_type
    return if expires_at.present?
    return unless issued_at.present? && permit_type.present? && permit_type.validity_months.present?

    self.expires_at = issued_at + permit_type.validity_months.months
  end
  # 🚅 add methods above.
end
