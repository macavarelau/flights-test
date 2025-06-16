class Passenger
  include Mongoid::Document
  
  # Custom fields
  field :external_id, type: Integer
  field :name, type: String
  field :has_connections, type: Boolean, default: false
  field :age, type: Integer
  field :flight_category, type: String
  field :reservation_id, type: String
  field :has_checked_baggage, type: Boolean, default: false

  # Validations - only name is required for updates
  validates :name, presence: true
  
  # Optional validations that only run if the field is present
  validates :age, numericality: { greater_than: 0 }, allow_nil: true
  validates :flight_category, 
           inclusion: { in: %w[Black Platinum Gold Normal economy] }, 
           allow_nil: true,
           allow_blank: true

  # These are only required on create
  validates :external_id, presence: true, on: :create
  validates :reservation_id, presence: true, on: :create

  # Embedded in Flight document
  embedded_in :flight

  # Callback to set external_id from id if not present
  before_validation :set_external_id_from_id

  private

  def set_external_id_from_id
    self.external_id = self.id if external_id.blank? && self.id.present?
  end
end 