# frozen_string_literal: true

module ActiveJob
  module QueueName
    extend ActiveSupport::Concern

    # Includes the ability to override the default queue name and prefix.
    module ClassMethods
      mattr_accessor :queue_name_prefix
      mattr_accessor :default_queue_name, default: "default"

      # Specifies the name of the queue to process the job on.
      #
      #   class PublishToFeedJob < ActiveJob::Base
      #     queue_as :feeds
      #
      #     def perform(post)
      #       post.to_feed!
      #     end
      #   end
      def queue_as(part_name = nil, &block)
        if block_given?
          self.queue_name = block
        else
          self.queue_name = queue_name_from_part(part_name)
        end
      end

      def queue_name_from_part(part_name) #:nodoc:
        queue_name = part_name || default_queue_name
        name_parts = [queue_name_prefix.presence, queue_name]
        name_parts.compact.join(queue_name_delimiter)
      end
    end

    class_methods do
      attr_writer :queue_name

      def queue_name
        if defined?(@queue_name) && !@queue_name.nil?
          @queue_name
        else
          queue_name_from_part(nil)
        end
      end
    end

    included do
      class_attribute :queue_name_delimiter, instance_accessor: false, default: "_"

      def queue_name
        if @queue_name.is_a?(Proc)
          instance_exec(&@queue_name).to_s
        else
          @queue_name
        end
      end
    end
  end
end
