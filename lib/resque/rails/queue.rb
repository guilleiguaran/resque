# Job class:
# class Archive
#   def initialize(repo_id, branch = 'master')
#     @repo_id, @branch = repo_id, branch
#   end
#
#   def run
#     Repository.find(@repo_id)
#     repo.create_archive(@branch)
#   end
# end
#
# Rails config/application.rb:
# config.queue = Resque::Rails::Queue.new
#
# Usage:
# job = Archive.new('rails/rails', 'master')
# Rails.queue.push(job)

module Resque
  module Rails
    class Queue
      def initialize(queue = :jobs)
        @queue = queue
      end

      def push(job)
        klass = job.class
        define_perform_method(klass) unless klass.respond_to?(:perform)
        Resque::Job.create(@queue, klass.to_s, job)
      end

      private
      def define_perform_method(klass)
        klass.define_singleton_method(:perform) do |job|
          job.run
        end
      end
    end
  end
end
