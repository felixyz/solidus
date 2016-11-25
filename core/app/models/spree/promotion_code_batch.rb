module Spree
  class PromotionCodeBatch < ActiveRecord::Base
    class CantProcessStartedBatch < StandardError
    end

    belongs_to :promotion, class_name: "Spree::Promotion"
    has_many :promotion_codes, class_name: "Spree::PromotionCode", dependent: :destroy

    validates :number_of_codes, numericality: { greater_than: 0 }
    validates_presence_of :base_code, :number_of_codes

    def finished?
      number_of_codes == promotion_codes.count
    end

    def process
      if promotion_codes.count.zero?
        PromotionCodeBatchJob.perform_later(self)
      else
        raise CantProcessStartedBatch.new("Batch #{id} already started")
      end
    end
  end
end
