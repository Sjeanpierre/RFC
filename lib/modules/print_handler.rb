module PrintHandler
  class View
    #this class will create a html view for all changes listed
    def initialize(changes)
      @changes = changes
    end

    def prepare
      content = prepare_content
      wrapper_template = File.read(Rails.root.join('lib', 'print_templates', 'page_wrapper.html.erb'))
      erb_template = ERB.new(wrapper_template)
      template_processor(erb_template, content)
    end

    def prepare_content
      content_template = File.read(Rails.root.join('lib', 'print_templates', 'print_template.html.erb'))
      erb_template = ERB.new(content_template)
      html_content = []
      @changes.each do |change|
        html_content.push(template_processor(erb_template, change))
      end
      html_content
    end

    def template_processor(template, data)
      @data = data
      template.result(binding)
    end

  end
end