class Avo::Resources::Worker < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :last_name, as: :text
    field :first_name, as: :text
    field :middle_name, as: :text
    field :employee_number, as: :text
    field :department, as: :text
    field :position, as: :text
    field :hire_date, as: :date
  end
end
