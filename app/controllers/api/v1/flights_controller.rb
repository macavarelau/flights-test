module Api
  module V1
    class FlightsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_flight, only: [:show, :update, :destroy]

      # GET /api/v1/flights
      def index
        @flights = Flight.all
        render json: @flights.as_json(camelize: true)
      end

      # GET /api/v1/flights/:flight_code
      def show
        render json: @flight.as_json(camelize: true)
      end

      # POST /api/v1/flights
      def create
        # Transform passenger IDs to external_ids
        params_with_external_ids = flight_params.deep_dup
        if params_with_external_ids[:passengers_attributes].present?
          params_with_external_ids[:passengers_attributes].each do |passenger|
            if passenger[:id].present?
              passenger[:external_id] = passenger.delete(:id)
            end
          end
        end

        @flight = Flight.new(params_with_external_ids)

        if @flight.save
          render json: @flight.as_json(camelize: true), status: :created
        else
          render json: { errors: @flight.errors }.as_json(camelize: true), 
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/flights/:flight_code
      def update
        if params[:flight][:passengers_attributes].present?
          params[:flight][:passengers_attributes].each do |passenger_params|
            # Find the passenger by external_id
            passenger = @flight.passengers.find_by(external_id: passenger_params[:id])
            
            if passenger
              # Update only the provided attributes
              passenger_params.except(:id).each do |key, value|
                passenger[key] = value unless value.nil?
              end
              
              unless passenger.save(validate: false)  # Skip validations for update
                render json: { 
                  errors: @flight.errors.full_messages,
                  passenger_errors: passenger.errors.full_messages 
                }.as_json(camelize: true), 
                status: :unprocessable_entity
                return
              end
            end
          end
        end

        if @flight.save  # Save the flight after updating passengers
          render json: @flight.as_json(camelize: true)
        else
          render json: { 
            errors: @flight.errors.full_messages,
            passenger_errors: @flight.passengers.map { |p| p.errors.full_messages }.flatten
          }.as_json(camelize: true), 
          status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/flights/:flight_code
      def destroy
        @flight.destroy
        render json: { message: "Flight successfully deleted" }, status: :ok
      end

      private

      def set_flight
        @flight = Flight.find_by(flight_code: params[:flight_code])
        render json: { error: 'Flight not found' }.as_json(camelize: true), 
               status: :not_found unless @flight
      end

      def flight_params
        params.require(:flight).permit(
          :flight_code,
          passengers_attributes: [
            :id,
            :name,
            :has_connections,
            :age,
            :flight_category,
            :reservation_id,
            :has_checked_baggage
          ]
        )
      end
    end
  end
end 