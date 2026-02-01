class Worker < ApplicationRecord
  include Discard::Model

  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  belongs_to :team
  # 🚅 add belongs_to associations above.

  has_many :certifications, dependent: :destroy
  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # Scopes
  default_scope -> { kept } # Exclude discarded by default
  scope :search_by_query, lambda { |query|
    where('employee_number ILIKE :q OR last_name ILIKE :q OR first_name ILIKE :q', q: "%#{query}%")
  }
  # 🚅 add scopes above.

  # Validations
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :employee_number, presence: true, uniqueness: { scope: :team_id }
  # 🚅 add validations above.

  # Cascade soft-delete to certifications
  after_discard do
    certifications.discard_all
  end

  after_undiscard do
    Certification.unscoped.where(worker_id: id).undiscard_all
  end
  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # Methods
  def full_name
    [last_name, first_name, middle_name].compact.join(' ')
  end
  # 🚅 add methods above.
end
