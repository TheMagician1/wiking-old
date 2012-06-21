class WikingLiquidHook < ChiliProject::Liquid::Tags::Tag

    def initialize(tag_name, markup, tokens)
        Rails.logger.info " => <#{tag_name} />"
        Rails.logger.info " => #{markup}"
        Rails.logger.info " => #{tokens.inspect}"
        super
    end

    def render(context)
        content = ''
        # TODO
        content
    end

end
