require_dependency 'redmine/wiki_formatting/macros'

module WikingMacrosDefinitionsPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :exec_macro, :custom
        end
    end

    module InstanceMethods

        def exec_macro_with_custom(name, obj, args)
            method_name = "macro_#{name.downcase}"
            unless respond_to?(method_name)
                macro = WikiMacro.find_by_name(name)
                macro.register! if macro
            end
            if method_name == 'macro_macro_list'
                available_macros = Redmine::WikiFormatting::Macros.class_variable_get(:@@available_macros)
                WikiMacro.all.each do |macro| # FIXME what about renamed/deleted macros?
                    macro.register! unless available_macros.has_key?(macro.name.to_sym)
                end
            end
            exec_macro_without_custom(name, obj, args)
        end

    end

end
