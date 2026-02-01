# Russian industrial permit types with actual penalty amounts
# Using find_or_create_by! for idempotency (Bullet Train requirement)

PERMIT_TYPES_DATA = [
  {
    name: 'Охрана труда',
    validity_months: 36,
    national_standard: 'Пост. Правительства 2464',
    penalty_amount: 130_000,
    penalty_article: 'ст. 5.27.1 КоАП',
    training_hours: 40,
    requires_protocol: true
  },
  {
    name: 'Электробезопасность II-V гр.',
    validity_months: 12,
    national_standard: 'Приказ Минтруда 903н',
    penalty_amount: 130_000,
    penalty_article: 'ст. 9.11 КоАП',
    training_hours: 72,
    requires_protocol: true
  },
  {
    name: 'Работы на высоте',
    validity_months: 12,
    national_standard: 'Приказ Минтруда 782н',
    penalty_amount: 130_000,
    penalty_article: 'ст. 5.27.1 КоАП',
    training_hours: 16,
    requires_protocol: true
  },
  {
    name: 'Пожарно-технический минимум',
    validity_months: 36,
    national_standard: 'Приказ МЧС 806',
    penalty_amount: 200_000,
    penalty_article: 'ст. 20.4 КоАП',
    training_hours: 28,
    requires_protocol: false
  },
  {
    name: 'Оказание первой помощи',
    validity_months: 36,
    national_standard: 'ст. 212 ТК РФ',
    penalty_amount: 130_000,
    penalty_article: 'ст. 5.27.1 КоАП',
    training_hours: 16,
    requires_protocol: false
  },
  {
    name: 'Работа с ГПМ (краны, тали)',
    validity_months: 12,
    national_standard: 'ФНП Приказ 461',
    penalty_amount: 300_000,
    penalty_article: 'ст. 9.1 КоАП',
    training_hours: 40,
    requires_protocol: true
  },
  {
    name: 'Работа в электроустановках',
    validity_months: 12,
    national_standard: 'ПТЭЭП',
    penalty_amount: 130_000,
    penalty_article: 'ст. 9.11 КоАП',
    training_hours: 72,
    requires_protocol: true
  },
  {
    name: 'Тепловые энергоустановки',
    validity_months: 12,
    national_standard: 'Приказ Минэнерго 115',
    penalty_amount: 130_000,
    penalty_article: 'ст. 9.11 КоАП',
    training_hours: 72,
    requires_protocol: true
  },
  {
    name: 'Работа в ограниченных пространствах',
    validity_months: 12,
    national_standard: 'Приказ Минтруда 902н',
    penalty_amount: 130_000,
    penalty_article: 'ст. 5.27.1 КоАП',
    training_hours: 16,
    requires_protocol: true
  },
  {
    name: 'Погрузочно-разгрузочные работы',
    validity_months: 12,
    national_standard: 'Приказ Минтруда 753н',
    penalty_amount: 130_000,
    penalty_article: 'ст. 5.27.1 КоАП',
    training_hours: 16,
    requires_protocol: true
  }
].freeze
