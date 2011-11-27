require_dependency 'redmine/wiki_formatting/textile/formatter'

module WikingFormatterPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            self::RULES << :block_wiking_blocks
            self::RULES << :inline_wiking_markers
            self::RULES << :inline_wiking_smileys
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        LT = "&lt;"
        GT = "&gt;"

        def textile_warning(tag, attrs, cite, content)
            attrs = shelve(attrs) if attrs
            "\t<div#{attrs} class=\"wiking flash #{tag}\">#{content}</div>"
        end

        alias textile_notice textile_warning
        alias textile_tip    textile_warning

        WIKING_BLOCK_RE = %r{#{LT}(warning|notice|tip)#{GT}(?:<br(?: /)?>)?(.*?)#{LT}/\1#{GT}}m

        def block_wiking_blocks(text)
            text.gsub!(WIKING_BLOCK_RE) do |match|
                "<div class=\"wiking flash #{$1}\">#{$2}</div>"
            end
            false
        end

        WIKING_MARKER_RE = %r{\{(#{LT}|<|\^)?(TODO|FIXME|UPDATE|NEW|FREE)(#{GT}|>)?\}}

        def inline_wiking_markers(text)
            text.gsub!(WIKING_MARKER_RE) do |match|
                attr, marker, right = $~[1..3]
                align = attr || right
                if align
                    case align
                    when GT, '>'
                        class_name = 'marker-right'
                    when LT, '<'
                        class_name = 'marker-left'
                    when '^'
                        class_name = 'marker-super'
                    else
                        class_name = ''
                    end
                end
                "<span class=\"wiking marker marker-#{marker.downcase} #{class_name}\"></span>"
            end
        end

        # TODO: support just ")"?

        WIKING_SMILEY_RE = {
            'smiley'      => ':-?\)',                  # :)
            'smiley2'     => '=-?\)',                  # =)
            'laughing'    => ':-?D',                   # :D
            'laughing2'   => '[=8]-?D',                # =D
            'crying'      => '[=8:][\'*]\(',           # :'(
            'sad'         => '[=8:]-?\(',              # :(
            'wink'        => ';-?[)D]',                # ;)
            'cheeky'      => '[=8:]-?[Ppb]',           # :P
            'shock'       => '[=8:]-?[Oo0]',           # :O
            'annoyed'     => '[=8:]-?[\\/]',           # :/
            'confuse'     => '[=8:]-?S',               # :S
            'straight'    => '[=8:]-?\|',              # :|
            'embarrassed' => '[=8:]-?[Xx]',            # :X
            'kiss'        => '[=8:]-?\*',              # :*
            'angel'       => '[Oo][=8:]-?\)',          # O:)
            'evil'        => '>[=8:;]-?[)(]',          # >:)
            'rock'        => 'B-?\)',                  # B)
            'rose'        => '@[)\}][-\\/\',;()>\}]*', # @}->-
            'exclamation' => '[\[(]![\])]',            # (!)
            'question'    => '[\[(]\?[\])]'            # (?)
        }

        def inline_wiking_smileys(text)
            WIKING_SMILEY_RE.each do |name, regexp| # TODO: support ! to disable
                text.gsub!(%r{(#{regexp})}) do |match| # FIXME: inside [...] ?
                    "<span class=\"wiking smiley smiley-#{name}\"></span>"
                end
            end
        end

    end

end
