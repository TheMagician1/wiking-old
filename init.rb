require 'redmine'
require 'dispatcher'

require_dependency 'wiking_hook'

RAILS_DEFAULT_LOGGER.info 'Starting WikiNG Plugin for Redmine'

Dispatcher.to_prepare :wiking_plugin do
    unless Redmine::WikiFormatting::Textile::Formatter.included_modules.include?(WikingFormatterPatch)
        Redmine::WikiFormatting::Textile::Formatter.send(:include, WikingFormatterPatch)
    end
    unless ApplicationHelper.included_modules.include?(WikingApplicationHelperPatch)
        ApplicationHelper.send(:include, WikingApplicationHelperPatch)
    end
end

Redmine::Plugin.register :wiking_plugin do
    name 'WikiNG'
    author 'Andriy Lesyuk'
    author_url 'http://www.andriylesyuk.com/'
    description 'Wiki Next Generation plugin extends Redmine Wiki syntax.'
    url 'http://projects.andriylesyuk.com/projects/wiking'
    version '0.0.1'
end

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
