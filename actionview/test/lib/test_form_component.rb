# frozen_string_literal: true

class FormLabelComponent < ActionView::Base
  def initialize(form:)
    @form = form
  end

  # Returns ActionView::OutputBuffer.
  def render_in(view_context, &block)
    self.class.compile
    @view_context = view_context
    rendered_template
  end

  def self.template
    <<~'erb'
      <%= @form.label :title do %>
        Test
      <% end %>
    erb
  end

  def self.compile
    @compiled ||= nil
    return if @compiled

    class_eval(
      "def rendered_template; @output_buffer = ActionView::OutputBuffer.new; " +
      ActionView::Template::Handlers::ERB.erb_implementation.new(template, trim: true).src +
      "; end"
    )

    @compiled = true
  end
end

class NestedFieldsComponent < ActionView::Base
  def initialize(form:, comment:)
    @form = form
    @comment = comment
  end

  # Returns ActionView::OutputBuffer.
  def render_in(view_context, &block)
    self.class.compile
    @view_context = view_context
    rendered_template
  end

  def self.template
    <<~'erb'
      <%= @form.fields_for "comment[]", @comment do |c| %>
        <%= c.text_field(:name) %>
      <% end %>
    erb
  end

  def self.compile
    @compiled ||= nil
    return if @compiled

    class_eval(
      "def rendered_template; @output_buffer = ActionView::OutputBuffer.new; " +
      ActionView::Template::Handlers::ERB.erb_implementation.new(template, trim: true).src +
      "; end"
    )

    @compiled = true
  end
end

class FieldsComponent < ActionView::Base
  def initialize(form:)
    @form = form
  end

  # Returns ActionView::OutputBuffer.
  def render_in(view_context, &block)
    self.class.compile
    @view_context = view_context
    rendered_template
  end

  def self.template
    <<~'erb'
      <%= @form.fields :comment do |c| %>
        <%= c.text_field(:dont_exist_on_model ) %>
      <% end %>
    erb
  end

  def self.compile
    @compiled ||= nil
    return if @compiled

    class_eval(
      "def rendered_template; @output_buffer = ActionView::OutputBuffer.new; " +
      ActionView::Template::Handlers::ERB.erb_implementation.new(template, trim: true).src +
      "; end"
    )

    @compiled = true
  end
end
