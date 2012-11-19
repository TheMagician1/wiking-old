require_dependency 'redmine/wiki_formatting/textile/helper'

module WikingWikiHelperPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method :wikitoolbar_for, :wikitoolbar_with_wiking_for
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def wikitoolbar_with_wiking_for(field_id)
            unless @heads_for_wiki_formatter_included
                content_for :header_tags do
                    javascript_include_tag('jstoolbar/jstoolbar') +
                    javascript_include_tag('jstoolbar/textile') +
                    javascript_include_tag("jstoolbar/lang/jstoolbar-#{current_language.to_s.downcase}") +
                    stylesheet_link_tag('jstoolbar')
                end
                @heads_for_wiki_formatter_included = true
            end

            if defined? ChiliProject
                url = url_for(:controller => 'help', :action => 'wiki_syntax')
            else
                url = "#{Redmine::Utils.relative_url_root}/help/wiki_syntax.html"
            end
            wiking_url = "#{Redmine::Utils.relative_url_root}/plugin_assets/wiking/help/wiki_syntax.html"
            help_link = l(:setting_text_formatting) + ': ' +
                link_to(l(:label_help), url, :class => 'help-link',
                    :onclick => "window.open(\"#{url}\", \"\", \"resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes\"); return false;") + ' &amp; ' +
                link_to(l(:label_more), wiking_url, :class => 'help-link',
                    :onclick => "window.open(\"#{wiking_url}\", \"\", \"resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes\"); return false;")

            javascript_tag("var wikiToolbar = new jsToolBar(document.getElementById('#{field_id}')); wikiToolbar.setHelpLink('#{escape_javascript(help_link)}'); wikiToolbar.draw();")
        end

    end

end
