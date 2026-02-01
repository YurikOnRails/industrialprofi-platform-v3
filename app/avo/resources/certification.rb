class Avo::Resources::Certification < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :worker, as: :belongs_to
    field :permit_type, as: :belongs_to
    field :issued_at, as: :date
    field :expires_at, as: :date
    field :document_number, as: :text
    field :protocol_number, as: :text
    field :protocol_date, as: :date
    field :training_center, as: :text
    field :next_check_date, as: :date
  end
end
