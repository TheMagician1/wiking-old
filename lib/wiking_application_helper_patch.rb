require_dependency 'application_helper'

module WikingApplicationHelperPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method_chain :parse_redmine_links, :wiking
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        WIKING_USER_RE = %r{([\s\(,\-\[\>]|^)(!)?(user)(\(([^\)]+?)\))?(?:(#)(\d+)|(:)([^"\s<>][^\s<>]*?|"[^"]+?"))(?=(?=[[:punct:]]\W)|,|\s|\]|<|$)}

        WIKING_CONDITION_RE = %r{!?\((date|version)\s*([<=>]=?)\s*([^\)]+)\)(.*?)\(\1\)}m

        def parse_redmine_links_with_wiking(text, project, obj, attr, only_path, options)
            parse_redmine_links_without_wiking(text, project, obj, attr, only_path, options)

            # Users:
            #   user#1 -> Link to user with id 1
            #   user:s-andy -> Link to user with username "s-andy"
            #   user:"s-andy" -> Link to user with username "s-andy"
            #   user(me)#1 | user(me):s-andy -> Display "me" instead of firstname and lastname
            text.gsub!(WIKING_USER_RE) do |m|
                leading, esc, prefix, display, sep, identifier = $1, $2, $3, $5, $6 || $8, $7 || $9
                link = nil
                if esc.nil?
                    if sep == '#'
                        oid = identifier.to_i
                        case prefix
                        when 'user'
                            if user = User.find_by_id(oid)
                                name = display || user.name
                                if user.active?
                                    link = link_to(h(name), { :only_path => only_path, :controller => 'users', :action => 'show', :id => user },
                                                              :class => 'user')
                                else
                                    link = h(name)
                                end
                            end
                        end
                    elsif sep == ':'
                        oname = identifier.gsub(%r{^"(.*)"$}, "\\1")
                        case prefix
                        when 'user'
                            if user = User.find_by_login(oname)
                                name = display || user.name
                                if user.active?
                                    link = link_to(h(name), { :only_path => only_path, :controller => 'users', :action => 'show', :id => user },
                                                              :class => 'user')
                                else
                                    link = h(name)
                                end
                            end
                        end
                    end
                end
                leading + (link || "#{prefix}#{display}#{sep}#{identifier}")
            end

            # FIXME: on preview always show?
            text.gsub!(WIKING_CONDITION_RE) do |m| # FIXME: move to textilizable_with_wiking
                tag, condition, value, content = $1, $2, $3, $4
                unless m[0,1] == '!'
                    result = false

                    case tag
                    when 'date'
                        begin
                            date = Date.parse(value)
                            today = Date.today
                            result = (today <=> date)
                        rescue
                            result = true
                        end
                    when 'version'
                        if project
                            name = value.gsub(%r{^"(.*)"$}, "\\1")
                            current = project.versions.find(:all).sort.reverse.select{ |v| v.is_a?(Version) && v.closed? }.first
                            if current
                                if version = project.versions.find_by_name(name)
                                    result = (current <=> version)
                                else
                                    result = (current.name <=> name)
                                end
                            else
                                result = -1
                            end
                        end
                    end

                    unless result === true || result === false
                        if condition[-1..-1] == '=' && result == 0
                            result = true
                        else
                            case condition[0,1]
                            when '<'
                                result = (result < 0)
                            when '>'
                                result = (result > 0)
                            else
                                result = false
                            end
                        end
                    end

                    result ? content : nil
                else
                    m[1..-1]
                end
            end
        end

    end

end
