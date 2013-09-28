require_dependency 'comments_controller'

module WikingCommentsControllerPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            include ERB::Util
            include ActionView::Helpers::TagHelper
            include ActionView::Helpers::FormHelper
            include ActionView::Helpers::FormTagHelper
            include ActionView::Helpers::FormOptionsHelper
            include ActionView::Helpers::JavaScriptHelper
            include ActionView::Helpers::PrototypeHelper
            include ActionView::Helpers::NumberHelper
            include ActionView::Helpers::UrlHelper
            include ActionView::Helpers::AssetTagHelper
            include ActionView::Helpers::TextHelper
            include ActionController::UrlWriter
            include ApplicationHelper

            after_filter :textilize_comment, :only => :create

            def self.default_url_options
                { :only_path => true }
            end

        end
    end

    module InstanceMethods

        # We need this as Redmine does not pass the object for comments to #textilizable
        def textilize_comment
            textilizable(@comment, :comments) if @comment && flash[:notice]
        rescue
        end

    end

end
