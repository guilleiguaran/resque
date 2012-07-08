require 'test_helper'
require 'resque/rails/queue'

describe "Resque::Rails::Queue" do
  before do
    Resque.redis.flushall
  end

  it "can put jobs on Resque queue" do
    assert_equal 0, Resque.size(:jobs)
    queue = Resque::Rails::Queue.new
    job = GoodRailsJob.new("coder")
    queue.push(job)

    assert_equal 1, Resque.size(:jobs)
    resque_job = Resque.reserve(:jobs)
    assert_kind_of Resque::Job, resque_job
    assert_equal GoodRailsJob, resque_job.payload_class
  end

  it "put processable jobs on Resque queue" do
    assert_equal 0, Resque.size(:jobs)
    queue = Resque::Rails::Queue.new
    job = GoodRailsJob.new("coder")
    queue.push(job)

    worker = Resque::Worker.new(:jobs)
    worker.process
    assert_equal 0, Resque.size(:jobs)
  end
end
