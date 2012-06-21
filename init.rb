require 'redmine'

require_dependency 'wiking_hook'

Rails.logger.info 'Starting WikiNG Plugin for Redmine'

# FIXME: user(Lluís)#456, please try r111 (TEST)
# FIXME: Test syntax links (TEST)

Rails.configuration.to_prepare do
    unless Redmine::WikiFormatting::Textile::Formatter.included_modules.include?(WikingFormatterPatch)
        Redmine::WikiFormatting::Textile::Formatter.send(:include, WikingFormatterPatch)
    end
    unless Redmine::WikiFormatting::Textile::Helper.included_modules.include?(WikingWikiHelperPatch)
        Redmine::WikiFormatting::Textile::Helper.send(:include, WikingWikiHelperPatch)
    end
    unless ApplicationHelper.included_modules.include?(WikingApplicationHelperPatch)
        ApplicationHelper.send(:include, WikingApplicationHelperPatch)
    end

    if defined? ChiliProject::Liquid::Tags # TODO
        #require_dependency 'chiliproject/liquid/tags/hook'

        #ChiliProject::Liquid::Tags.register_tag('hook', Download, :html => true)
    end
end

Redmine::Plugin.register :wiking do
    name 'WikiNG'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Wiki Next Generation plugin extends Redmine Wiki syntax.'
    url 'http://projects.andriylesyuk.com/projects/wiking'
    version '0.0.2'

    project_module :wiki do
        permission :view_hidden_content, {}
    end
end

unless defined? ChiliProject::Liquid::Tags

    Redmine::WikiFormatting::Macros.register do
        desc "Adds new Redmine hook to Wiki page and calls it. Example:\n\n  !{{hook(name, argument=value)}}"
        macro :hook do |page, args|
            if args.size > 0
                hook = args.shift

                params = []
                options = {}
                args.each do |arg|
                    if arg =~ %r{^(.+)\=(.+)$}
                        options[$1.downcase.to_sym] = $2
                    else
                        params << arg
                    end
                end

                call_hook("wiking_hook_#{hook}", { :page => page, :args => params, :options => options })
            end
        end
    end

end
