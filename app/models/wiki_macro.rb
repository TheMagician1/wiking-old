require 'cgi'

class WikiMacro < ActiveRecord::Base
    include ERB::Util

    NAME_MAX_LENGTH = 30

    validates_presence_of :name, :description, :content
    validates_length_of :name, :in => 1..NAME_MAX_LENGTH
    validates_format_of :name, :with => %r{^[a-z0-9_]+$}

    validate :validate_name

    MACRO_ARGUMENT_RE = %r{%(url)?(?:\{([^{=}]*)\}|\[([0-9]*)\]|\((\**)\))}

    def to_s
        "{{#{name}}}"
    end

    def exec(args, params, text)
        self.content.gsub(MACRO_ARGUMENT_RE) do |match|
            escape = $1
            if $2
                param = $2.downcase.to_sym
                params.has_key?(param) ? self.escape(params[param], escape) : ''
            elsif $3
                index = $3.to_i
                (index > 0 && index <= args.size) ? self.escape(args[index-1], escape) : ''
            else
                self.escape(text)
            end
        end
    end

    def escape(value, type)
        type.downcase! if type.respond_to?(:downcase!)
        case type
        when 'url'
            value = CGI.escape(value)
        end
        h(value)
    end

    def register!
        wiki_macro = self
        macro_desc = self.description
        macro_name = self.name.to_sym
        Redmine::WikiFormatting::Macros.register do
            desc macro_desc
            macro macro_name do |*args|
                named = {}
                unnamed = []
                obj = args.shift
                text = args.size > 1 ? args.pop : nil
                args.shift.each do |arg|
                    if arg =~ %r{^([^{=}]+)=(?:(['"])([^\2]*)\2|(.*))$}
                        named[$1.downcase.to_sym] = $2 ? $3 : $4
                    else
                        arg.gsub!(%r{^(['"])(.*)\1$}, '\\2')
                        unnamed << arg
                    end
                end
                wiki_macro.reload.exec(unnamed, named, text)
            end
        end
    end

    def update_description!
        if Redmine::WikiFormatting::Macros.respond_to?(:available_macros)
            Redmine::WikiFormatting::Macros.available_macros[name.to_sym][:desc] = description
        else
            available_macros = Redmine::WikiFormatting::Macros.class_variable_get(:@@available_macros)
            available_macros[name.to_sym] = description
            Redmine::WikiFormatting::Macros.class_variable_set(:@@available_macros, available_macros)
        end
    end

    def unregister!
        self.class.unregister!(self.name)
    end

    def self.unregister!(name)
        if Redmine::WikiFormatting::Macros.respond_to?(:available_macros)
            Redmine::WikiFormatting::Macros.available_macros.delete(name.to_sym)
        else
            available_macros = Redmine::WikiFormatting::Macros.class_variable_get(:@@available_macros)
            available_macros.delete(name.to_sym)
            Redmine::WikiFormatting::Macros.class_variable_set(:@@available_macros, available_macros)
        end
        Redmine::WikiFormatting::Macros::Definitions.send(:remove_method, "macro_#{name.downcase}")
    end

    def self.register_all!
        all.each do |macro|
            macro.register!
        end
    end

private

    def validate_name
        if name_changed?
            available_macros = Redmine::WikiFormatting::Macros.class_variable_get(:@@available_macros) # not needed for Redmine 2.x
            if available_macros.has_key?(name.to_sym) ||
                Redmine::WikiFormatting::Macros::Definitions.method_defined?("macro_#{name.downcase}")
                errors.add(:name, :taken)
            end
        end
    end

end
