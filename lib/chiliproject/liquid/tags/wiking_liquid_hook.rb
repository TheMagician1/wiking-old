class WikingLiquidHook < ChiliProject::Liquid::Tags::Tag

    def initialize(tag_name, markup, tokens)
        @arguments = []
        @options = {}

        markup = markup.strip
        if markup =~ %r{^\((.*)\)$}
            markup = $2
        end

        if markup.present?
            markup.split(',').each do |arg|
                arg.strip!
                if arg =~ %r{^([^=]+)\=(.*)$}
                    name, value = $1.strip.downcase.to_sym, $2.strip
                    if value =~ %r{^(["'])(.*)\1$}
                        value = $2
                    end
                    @options[name] = value
                else
                    @arguments << arg
                end
            end

            @hook = @arguments.shift
        end

        Rails.logger.info " >>> #{@hook.inspect}"
        Rails.logger.info " >>> ARGUMENTS: #{@arguments.inspect}"
        Rails.logger.info " >>> OPTIONS: #{@options.inspect}"

        super
    end

    def render(context)
        content = ''

        unless @hook.empty?
            # TODO: context.registers[:object].... page? # :page => page
            call_hook("wiking_hook_#{@hook}", { :args => @arguments, :options => @options })
        end

        content
    end

end
