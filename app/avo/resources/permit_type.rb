class Avo::Resources::PermitType < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :name, as: :text
    field :validity_months, as: :number
    field :national_standard, as: :text
    field :penalty_amount, as: :number
    field :penalty_article, as: :text
    field :training_hours, as: :number
    field :requires_protocol, as: :boolean
  end
end
