class CalculateStatsJob < ApplicationJob
  queue_as :default

  def perform
    count_estimator = TwCountEstimatorService.new
    count_estimator.perform
  end
end
