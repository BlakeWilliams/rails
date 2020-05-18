# frozen_string_literal: true

class TestFormComponent < ActionView::Base
  # Entrypoint for rendering. Called by ActionView::RenderingHelper#render.
  #
  # Returns ActionView::OutputBuffer.
  def render_in(view_context, &block)
    self.class.compile
    @view_context = view_context
    @content = view_context.capture(&block) if block_given?
    @view_context.with_child_renderer self do
      @view_context.with_output_buffer ActionView::OutputBuffer.new do
        rendered_template
      end
    end
  end

  def self.template
    <<~'erb'
    <%= form_for Customer.new, url: "#" do |form| %>
      <%= render TestFormGroupComponent.new(form: form) %>
    <% end %>
    erb
  end

  def self.compile
    @compiled ||= nil
    return if @compiled

    class_eval(
      "def rendered_template; " +
      ActionView::Template::Handlers::ERB.erb_implementation.new(template, trim: true).src +
      "; end"
    )

    @compiled = true
  end
end

class TestFormGroupComponent < ActionView::Base
  def initialize(form:)
    @form = form
  end
  # Entrypoint for rendering. Called by ActionView::RenderingHelper#render.
  #
  # Returns ActionView::OutputBuffer.
  def render_in(view_context, &block)
    self.class.compile
    @view_context = view_context
    @content = view_context.capture(&block) if block_given?
    @output_buffer = ActionView::OutputBuffer.new;
    @view_context.with_child_renderer self do
      @view_context.with_output_buffer ActionView::OutputBuffer.new do
        rendered_template
      end
    end
  end

  def self.template
    <<~'erb'
      <%= @form.label :name do %>
        Test
        <%= @form.text_field :name %>
      <% end %>
    erb
  end

  def self.compile
    @compiled ||= nil
    return if @compiled

    class_eval(
      "def rendered_template;" +
      ActionView::Template::Handlers::ERB.erb_implementation.new(template, trim: true).src +
      "; end"
    )

    @compiled = true
  end
end
