# IndustrialPROFI — MVP TODO List (Bullet Train Way)

> **Инструкция для ИИ:** Следуй этому плану последовательно. После выполнения каждого шага ставь `[x]` вместо `[ ]`. При возникновении ошибок — исправь и продолжай.

---

## Философия разработки (Bullet Train Way)

### Подход Bullet Train:

1. **DOMAIN MODEL** — Продумай модель данных
2. **SCAFFOLD** — Сгенерируй через super_scaffold (создаёт ~30 файлов)
3. **MIGRATE** — Запусти миграции
4. **CUSTOMIZE** — Добавь бизнес-логику в сгенерированные файлы
5. **TEST** — Добавь тесты в сгенерированные test файлы
6. **VERIFY** — Запусти тесты и проверь UI

### Что генерирует super_scaffold автоматически:
- Model с belongs_to ассоциациями
- Controller (CRUD)
- Views (index, show, new, edit, _form)
- Factory для тестов
- Пустой test файл
- API controller + serializer
- Routes
- Localization YAML
- Permissions (CanCanCan)

### Команды для тестирования:

```bash
# Запуск всех unit тестов
bin/rails test

# Запуск конкретного теста
bin/rails test test/models/permit_type_test.rb

# Запуск системных тестов
bin/rails test:system

# Отладка с видимым браузером
MAGIC_TEST=1 bin/rails test:system
```

---

## ФАЗА 0: Подготовка окружения

- [x] **0.1** Проверить что PostgreSQL работает
  ```bash
  pg_isready
  # Ожидаемый ответ: accepting connections
  ```

- [x] **0.2** Проверить что Redis работает
  ```bash
  redis-cli ping
  # Ожидаемый ответ: PONG
  ```

- [x] **0.3** Проверить состояние базы данных
  ```bash
  bin/rails db:migrate:status
  ```

- [x] **0.4** Убедиться что существующие тесты проходят
  ```bash
  bin/rails test
  ```

---

## ФАЗА 1: Добавление gems

- [x] **1.1** Добавить gems в Gemfile
  
  Открыть `Gemfile` и добавить после секции Bullet Train:
  ```ruby
  # IndustrialPROFI gems
  gem "discard", "~> 1.3"           # Soft deletes
  gem "sidekiq-cron", "~> 2.0"      # Scheduled jobs
  gem "caxlsx", "~> 4.1"            # Excel generation
  gem "caxlsx_rails", "~> 0.6"      # Rails integration for Excel
  gem "roo", "~> 2.10"              # Excel import
  gem "csv"                         # Required for Ruby 3.4+
  ```

- [x] **1.2** Установить gems
  ```bash
  bundle install
  ```

- [x] **1.3** Проверить что тесты всё ещё проходят
  ```bash
  bin/rails test
  ```

---

## ФАЗА 2: Генерация PermitType

### 2.1 Scaffold + Migrate

- [x] **2.1.1** Сгенерировать PermitType через super_scaffold
  ```bash
  bin/rails generate super_scaffold PermitType Team \
    name:text_field \
    validity_months:number_field \
    national_standard:text_field \
    penalty_amount:number_field \
    penalty_article:text_field \
    training_hours:number_field \
    requires_protocol:boolean
  ```
  
  > **Что будет создано:**
  > - `app/models/permit_type.rb`
  > - `app/controllers/account/permit_types_controller.rb`
  > - `app/views/account/permit_types/*`
  > - `test/factories/permit_types.rb`
  > - `test/models/permit_type_test.rb`
  > - `config/locales/en/permit_types.en.yml`

- [x] **2.1.2** Запустить миграции
  ```bash
  bin/rails db:migrate
  ```

- [x] **2.1.3** Проверить что scaffold работает
  ```bash
  bin/rails test
  bin/dev  # Открыть http://localhost:3000, создать PermitType
  ```

### 2.2 Добавить валидации в модель

- [x] **2.2.1** Открыть `app/models/permit_type.rb` и добавить валидации:
  ```ruby
  class PermitType < ApplicationRecord
    # ... existing Bullet Train code ...
    
    # Validations
    validates :name, presence: true
    validates :validity_months, numericality: { greater_than: 0 }, allow_nil: true
    validates :penalty_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  end
  ```

### 2.3 Добавить тесты в сгенерированный файл

- [x] **2.3.1** Открыть `test/models/permit_type_test.rb` и добавить тесты:
  ```ruby
  require "test_helper"

  class PermitTypeTest < ActiveSupport::TestCase
    def setup
      @team = create(:team)
    end

    test "should be valid with all attributes" do
      permit_type = build(:permit_type, team: @team)
      assert permit_type.valid?
    end

    test "should require name" do
      permit_type = build(:permit_type, team: @team, name: nil)
      assert_not permit_type.valid?
      assert_includes permit_type.errors[:name], "can't be blank"
    end

    test "should require validity_months to be positive" do
      permit_type = build(:permit_type, team: @team, validity_months: 0)
      assert_not permit_type.valid?
    end

    test "should allow nil validity_months" do
      permit_type = build(:permit_type, team: @team, validity_months: nil)
      assert permit_type.valid?
    end

    test "should require penalty_amount to be non-negative" do
      permit_type = build(:permit_type, team: @team, penalty_amount: -100)
      assert_not permit_type.valid?
    end

    test "should belong to team" do
      permit_type = create(:permit_type, team: @team)
      assert_equal @team, permit_type.team
    end
  end
  ```

- [x] **2.3.2** Обновить фабрику `test/factories/permit_types.rb`:
  ```ruby
  FactoryBot.define do
    factory :permit_type do
      team
      sequence(:name) { |n| "Охрана труда #{n}" }
      validity_months { 36 }
      national_standard { "Постановление 2464" }
      penalty_amount { 130000 }
      penalty_article { "ст. 5.27.1 КоАП" }
      training_hours { 40 }
      requires_protocol { true }
    end
  end
  ```

- [x] **2.3.3** Запустить тесты
  ```bash
  bin/rails test test/models/permit_type_test.rb
  ```

---

## ФАЗА 3: Генерация Worker

### 3.1 Scaffold + Migrate

- [x] **3.1.1** Сгенерировать Worker через super_scaffold
  ```bash
  bin/rails generate super_scaffold Worker Team \
    last_name:text_field \
    first_name:text_field \
    middle_name:text_field \
    employee_number:text_field \
    department:text_field \
    position:text_field \
    hire_date:date_field
  ```

- [x] **3.1.2** Добавить миграцию для soft-delete
  ```bash
  bin/rails generate migration AddDiscardedAtToWorkers discarded_at:datetime:index
  ```

- [x] **3.1.3** Запустить миграции
  ```bash
  bin/rails db:migrate
  ```

### 3.2 Добавить бизнес-логику в модель

- [x] **3.2.1** Открыть `app/models/worker.rb` и добавить:
  ```ruby
  class Worker < ApplicationRecord
    include Discard::Model
    
    # ... existing Bullet Train code ...
    
    # Validations
    validates :last_name, presence: true
    validates :first_name, presence: true
    validates :employee_number, presence: true, uniqueness: { scope: :team_id }
    
    # Scopes
    default_scope -> { kept }  # Exclude discarded by default
    
    # Methods
    def full_name
      [last_name, first_name, middle_name].compact.join(" ")
    end
  end
  ```

### 3.3 Добавить тесты

- [x] **3.3.1** Обновить `test/models/worker_test.rb`:
  ```ruby
  require "test_helper"

  class WorkerTest < ActiveSupport::TestCase
    def setup
      @team = create(:team)
    end

    test "should be valid with all attributes" do
      worker = build(:worker, team: @team)
      assert worker.valid?
    end

    test "should require last_name" do
      worker = build(:worker, team: @team, last_name: nil)
      assert_not worker.valid?
    end

    test "should require first_name" do
      worker = build(:worker, team: @team, first_name: nil)
      assert_not worker.valid?
    end

    test "should require employee_number" do
      worker = build(:worker, team: @team, employee_number: nil)
      assert_not worker.valid?
    end

    test "should have unique employee_number within team" do
      create(:worker, team: @team, employee_number: "TN-001")
      worker2 = build(:worker, team: @team, employee_number: "TN-001")
      assert_not worker2.valid?
    end

    test "should allow same employee_number in different teams" do
      team2 = create(:team)
      create(:worker, team: @team, employee_number: "TN-001")
      worker2 = build(:worker, team: team2, employee_number: "TN-001")
      assert worker2.valid?
    end

    test "full_name should return formatted name" do
      worker = build(:worker, last_name: "Иванов", first_name: "Иван", middle_name: "Иванович")
      assert_equal "Иванов Иван Иванович", worker.full_name
    end

    test "should support soft delete" do
      worker = create(:worker, team: @team)
      worker.discard
      assert worker.discarded?
    end
  end
  ```

- [x] **3.3.2** Обновить фабрику `test/factories/workers.rb`:
  ```ruby
  FactoryBot.define do
    factory :worker do
      team
      sequence(:last_name) { |n| "Иванов#{n}" }
      sequence(:first_name) { |n| "Иван#{n}" }
      middle_name { "Иванович" }
      sequence(:employee_number) { |n| "TN-#{n.to_s.rjust(6, '0')}" }
      department { "Цех №1" }
      position { "Электромонтёр 5р" }
      hire_date { Date.current - 1.year }
    end
  end
  ```

- [x] **3.3.3** Запустить тесты
  ```bash
  bin/rails test test/models/worker_test.rb
  ```

---

## ФАЗА 4: Генерация Certification

### 4.1 Scaffold + Migrate

- [x] **4.1.1** Сгенерировать Certification (nested под Worker)
  ```bash
  bin/rails generate super_scaffold Certification Worker,Team \
    permit_type_id:super_select{class_name=PermitType} \
    issued_at:date_field \
    expires_at:date_field \
    document_number:text_field \
    protocol_number:text_field \
    protocol_date:date_field \
    training_center:text_field \
    next_check_date:date_field
  ```
  
  > **Важно:** Bullet Train попросит добавить метод `valid_permit_types`

- [x] **4.1.2** Добавить миграцию для soft-delete
  ```bash
  bin/rails generate migration AddDiscardedAtToCertifications discarded_at:datetime:index
  ```

- [x] **4.1.3** Запустить миграции
  ```bash
  bin/rails db:migrate
  ```

### 4.2 Добавить бизнес-логику

- [x] **4.2.1** Открыть `app/models/certification.rb` и добавить:
  ```ruby
  class Certification < ApplicationRecord
    include Discard::Model
    
    # ... existing Bullet Train code ...
    
    # Callbacks
    before_validation :set_expires_at_from_permit_type
    
    # Validations
    validates :issued_at, presence: true
    validates :permit_type, presence: true
    
    # Scopes
    default_scope -> { kept }
    scope :expired, -> { where("expires_at < ?", Date.current) }
    scope :critical, -> { where("expires_at >= ? AND expires_at <= ?", Date.current, Date.current + 7.days) }
    scope :attention, -> { where("expires_at > ? AND expires_at <= ?", Date.current + 7.days, Date.current + 30.days) }
    scope :expiring_soon, ->(days) { where("expires_at <= ?", Date.current + days.days) }
    
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
      return :expired if expires_at < Date.current
      return :critical if expires_at <= Date.current + 7.days
      return :attention if expires_at <= Date.current + 30.days
      :valid
    end
    
    private
    
    def set_expires_at_from_permit_type
      return if expires_at.present?
      return unless issued_at.present? && permit_type.present?
      
      self.expires_at = issued_at + permit_type.validity_months.months
    end
  end
  ```

### 4.3 Добавить тесты

- [x] **4.3.1** Обновить `test/models/certification_test.rb`:
  ```ruby
  require "test_helper"

  class CertificationTest < ActiveSupport::TestCase
    def setup
      @team = create(:team)
      @permit_type = create(:permit_type, team: @team, validity_months: 12)
      @worker = create(:worker, team: @team)
    end

    test "should be valid with all attributes" do
      cert = build(:certification, worker: @worker, permit_type: @permit_type)
      assert cert.valid?
    end

    test "should require issued_at" do
      cert = build(:certification, worker: @worker, permit_type: @permit_type, issued_at: nil)
      assert_not cert.valid?
    end

    test "should auto-calculate expires_at" do
      cert = build(:certification, worker: @worker, permit_type: @permit_type,
                   issued_at: Date.new(2024, 1, 15), expires_at: nil)
      cert.valid?
      assert_equal Date.new(2025, 1, 15), cert.expires_at
    end

    test "should not override manual expires_at" do
      cert = build(:certification, worker: @worker, permit_type: @permit_type,
                   issued_at: Date.new(2024, 1, 15), expires_at: Date.new(2024, 6, 30))
      cert.valid?
      assert_equal Date.new(2024, 6, 30), cert.expires_at
    end

    test "days_until_expiry should return correct value" do
      cert = build(:certification, expires_at: Date.current + 10.days)
      assert_equal 10, cert.days_until_expiry
    end

    test "status should be :expired when past due" do
      cert = build(:certification, expires_at: Date.current - 1.day)
      assert_equal :expired, cert.status
    end

    test "status should be :critical within 7 days" do
      cert = build(:certification, expires_at: Date.current + 5.days)
      assert_equal :critical, cert.status
    end

    test "status should be :attention within 30 days" do
      cert = build(:certification, expires_at: Date.current + 20.days)
      assert_equal :attention, cert.status
    end

    test "status should be :valid after 30 days" do
      cert = build(:certification, expires_at: Date.current + 60.days)
      assert_equal :valid, cert.status
    end

    test "valid_permit_types should return team permit types" do
      cert = build(:certification, worker: @worker)
      assert_includes cert.valid_permit_types, @permit_type
    end

    test "expired scope should work" do
      expired = create(:certification, worker: @worker, permit_type: @permit_type,
                       expires_at: Date.current - 1.day)
      valid = create(:certification, worker: @worker, 
                     permit_type: create(:permit_type, team: @team),
                     expires_at: Date.current + 60.days)
      
      assert_includes Certification.expired, expired
      assert_not_includes Certification.expired, valid
    end
  end
  ```

- [x] **4.3.2** Обновить фабрику `test/factories/certifications.rb`:
  ```ruby
  FactoryBot.define do
    factory :certification do
      worker
      permit_type { association :permit_type, team: worker.team }
      team { worker.team }
      issued_at { Date.current - 6.months }
      expires_at { Date.current + 6.months }
      sequence(:document_number) { |n| "УД-2024-#{n.to_s.rjust(4, '0')}" }
      sequence(:protocol_number) { |n| "ПР-2024-#{n.to_s.rjust(4, '0')}" }
      protocol_date { issued_at }
      training_center { "УЦ Профессионал" }
    end
  end
  ```

- [x] **4.3.3** Запустить тесты
  ```bash
  bin/rails test test/models/certification_test.rb
  ```

---

## ФАЗА 5: Каскадный soft-delete

- [x] **5.1** Добавить каскад в `app/models/worker.rb`:
  ```ruby
  # После include Discard::Model
  after_discard do
    certifications.discard_all
  end
  
  after_undiscard do
    certifications.undiscard_all
  end
  ```

- [x] **5.2** Добавить тесты в `test/models/worker_test.rb`:
  ```ruby
  test "should discard certifications when worker discarded" do
    worker = create(:worker, team: @team)
    permit_type = create(:permit_type, team: @team)
    cert = create(:certification, worker: worker, permit_type: permit_type)
    
    worker.discard
    cert.reload
    
    assert cert.discarded?
  end

  test "should undiscard certifications when worker undiscarded" do
    worker = create(:worker, team: @team)
    permit_type = create(:permit_type, team: @team)
    cert = create(:certification, worker: worker, permit_type: permit_type)
    
    worker.discard
    worker.undiscard
    cert.reload
    
    assert_not cert.discarded?
  end
  ```

- [x] **5.3** Запустить тесты
  ```bash
  bin/rails test test/models/worker_test.rb
  ```

---

## ФАЗА 6: Seed Data (Bullet Train Way)

- [x] **6.1** Создать `db/seeds/permit_types.rb`:
  ```ruby
  # Russian industrial permit types with actual penalty amounts
  # Using find_or_create_by! for idempotency (Bullet Train requirement)
  
  PERMIT_TYPES_DATA = [
    { name: "Охрана труда", validity_months: 36, national_standard: "Пост. Правительства 2464", 
      penalty_amount: 130000, penalty_article: "ст. 5.27.1 КоАП", training_hours: 40, requires_protocol: true },
    { name: "Электробезопасность II-V гр.", validity_months: 12, national_standard: "Приказ Минтруда 903н",
      penalty_amount: 130000, penalty_article: "ст. 9.11 КоАП", training_hours: 72, requires_protocol: true },
    { name: "Работы на высоте", validity_months: 12, national_standard: "Приказ Минтруда 782н",
      penalty_amount: 130000, penalty_article: "ст. 5.27.1 КоАП", training_hours: 16, requires_protocol: true },
    { name: "Пожарно-технический минимум", validity_months: 36, national_standard: "Приказ МЧС 806",
      penalty_amount: 200000, penalty_article: "ст. 20.4 КоАП", training_hours: 28, requires_protocol: false },
    { name: "Оказание первой помощи", validity_months: 36, national_standard: "ст. 212 ТК РФ",
      penalty_amount: 130000, penalty_article: "ст. 5.27.1 КоАП", training_hours: 16, requires_protocol: false },
    { name: "Работа с ГПМ (краны, тали)", validity_months: 12, national_standard: "ФНП Приказ 461",
      penalty_amount: 300000, penalty_article: "ст. 9.1 КоАП", training_hours: 40, requires_protocol: true },
    { name: "Работа в электроустановках", validity_months: 12, national_standard: "ПТЭЭП",
      penalty_amount: 130000, penalty_article: "ст. 9.11 КоАП", training_hours: 72, requires_protocol: true },
    { name: "Тепловые энергоустановки", validity_months: 12, national_standard: "Приказ Минэнерго 115",
      penalty_amount: 130000, penalty_article: "ст. 9.11 КоАП", training_hours: 72, requires_protocol: true },
    { name: "Работа в ограниченных пространствах", validity_months: 12, national_standard: "Приказ Минтруда 902н",
      penalty_amount: 130000, penalty_article: "ст. 5.27.1 КоАП", training_hours: 16, requires_protocol: true },
    { name: "Погрузочно-разгрузочные работы", validity_months: 12, national_standard: "Приказ Минтруда 753н",
      penalty_amount: 130000, penalty_article: "ст. 5.27.1 КоАП", training_hours: 16, requires_protocol: true }
  ].freeze
  ```

- [x] **6.2** Обновить `db/seeds.rb` (идемпотентно):
  ```ruby
  # Add at the end of db/seeds.rb
  require_relative "seeds/permit_types"
  
  # Create default permit types for each team (idempotent)
  if Rails.env.development? || Rails.env.test?
    Team.find_each do |team|
      PERMIT_TYPES_DATA.each do |attrs|
        team.permit_types.find_or_create_by!(name: attrs[:name]) do |pt|
          pt.assign_attributes(attrs.except(:name))
        end
      end
    end
    puts "Permit types seeded: #{PermitType.count} total"
  end
  ```

- [x] **6.3** Запустить seeds (можно запускать многократно)
  ```bash
  bin/rails db:seed
  bin/rails db:seed  # Повторный запуск не создаёт дубликаты
  ```

---

## ФАЗА 7: Финальная проверка

- [x] **7.1** Запустить все тесты
  ```bash
  bin/rails test
  ```

- [ ] **7.2** Проверить UI
  ```bash
  bin/dev
  ```
  
  Чек-лист:
  - [ ] Регистрация работает
  - [ ] Можно создать PermitType
  - [ ] Можно создать Worker
  - [ ] Можно создать Certification (super_select показывает PermitTypes)
  - [ ] expires_at автоматически рассчитывается
  - [ ] Soft-delete Worker каскадно удаляет Certifications

- [ ] **7.3** Коммит
  ```bash
  git add -A
  git commit -m "[PHASE-1] Generate core models: PermitType, Worker, Certification with business logic"
  ```

---

## Прогресс

| Фаза | Описание | Статус |
|------|----------|--------|
| 0 | Подготовка окружения | ✅ Завершено |
| 1 | Добавление gems | ✅ Завершено |
| 2 | PermitType: scaffold → customize → test | ✅ Завершено |
| 3 | Worker: scaffold → customize → test | ✅ Завершено |
| 4 | Certification: scaffold → customize → test | ✅ Завершено |
| 5 | Каскадный soft-delete | ✅ Завершено |
| 6 | Seed data | ✅ Завершено |
| 7 | Финальная проверка | 🔄 В процессе |

---

## Важные заметки

### Bullet Train генерирует автоматически:
- Фабрики в `test/factories/`
- Пустые тесты в `test/models/`
- Локализацию в `config/locales/en/`

### После каждого super_scaffold:
1. Запусти `bin/rails db:migrate`
2. Проверь что приложение работает: `bin/dev`
3. Добавь валидации и бизнес-логику в модель
4. Добавь тесты в сгенерированный test файл
5. Обнови фабрику если нужно
6. Запусти тесты: `bin/rails test`

### Идемпотентность seeds:
Bullet Train требует чтобы `db:seed` можно было запускать многократно без создания дубликатов. Используй `find_or_create_by!`.
