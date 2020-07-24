module Api
    module V1
        class CorporationsController < Api::BaseController

            def index
                respond_with CorporationSerializer.new(Corporation.all, is_collection: true).serialized_json
            end
        end
    end
end