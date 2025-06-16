class Flight
  include Mongoid::Document
  include Mongoid::Timestamps

  field :flight_code, type: String

  # Embedded array of passengers
  embeds_many :passengers

  # Accept nested attributes for passengers
  accepts_nested_attributes_for :passengers, allow_destroy: true, update_only: true

  # Validations
  validates :flight_code, presence: true, uniqueness: true
  validates :passengers, presence: true

  # Index for faster queries
  index({ flight_code: 1 }, { unique: true })

  # Alias for camelCase attributes
  alias_attribute :flightCode, :flight_code
end