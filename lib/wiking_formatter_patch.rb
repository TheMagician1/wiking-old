require_dependency 'redmine/wiki_formatting/textile/formatter'

module WikingFormatterPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            self::RULES << :block_wiking_blocks
            self::RULES << :inline_wiking_markers
            self::RULES << :inline_wiking_smileys
            self::RULES << :inline_dashes
            self::RULES << :inline_apostrophe
            self::RULES << :inline_arrows
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
                "<span class=\"wiking marker marker-#{marker.downcase} #{class_name}\" title=\"#{marker}\"></span>"
            end
        end

        WIKING_SMILEY_RE = {
            'smiley'      => ':-?\)',                  # :)
            'smiley2'     => '=-?\)',                  # =)
            'laughing'    => ':-?D',                   # :D
            'laughing2'   => '[=]-?D',                 # =D
            'crying'      => '[=:][\'*]\(',            # :'(
            'sad'         => '[=:]-?\(',               # :(
            'wink'        => ';-?[)D]',                # ;)
            'cheeky'      => '[=:]-?[Ppb]',            # :P
            'shock'       => '[=:]-?[Oo0]',            # :O
            'annoyed'     => '[=:]-?[\\/]',            # :/
            'confuse'     => '[=:]-?S',                # :S
            'straight'    => '[=:]-?[\|\]]',           # :|
            'embarrassed' => '[=:]-?[Xx]',             # :X
            'kiss'        => '[=:]-?\*',               # :*
            'angel'       => '[Oo][=:]-?\)',           # O:)
            'evil'        => '>[=:;]-?[)(]',           # >:) # FIXME: http://projects.andriylesyuk.com/projects/wiking/wiki
            'rock'        => 'B-?\)',                  # B)
            'rose'        => '@[)\}][-\\/\',;()>\}]*', # @}->-
            'exclamation' => '[\[(]![\])]',            # (!)
            'question'    => '[\[(]\?[\])]'            # (?)
        }

        def inline_wiking_smileys(text)
            WIKING_SMILEY_RE.each do |name, regexp|
                text.gsub!(%r{(\s|>|^)(!)?(#{regexp})(?=\W|$)}m) do |match|
                    leading, esc, smiley = $1, $2, $3
                    if esc.nil?
                        leading + "<span title=\"#{smiley}\" class=\"wiking smiley smiley-#{name}\"></span>"
                    else
                        leading + smiley
                    end
                end
            end
        end

        def inline_dashes(text)
            text.gsub!(%r{(-{2,3})}) do |match|
                case $1
                when '--'
                    '&ndash;'
                else
                    '&mdash;'
                end
            end
        end

        def inline_apostrophe(text)
            text.gsub!(%r{(\w)'}) do |match|
                "#{$1}&rsquo;"
            end
        end

        WIKING_ARROWS = {
            '<=>' => 'hArr',
            '<->' => 'harr',
            '<='  => 'lArr',
            '<-'  => 'larr',
            '=>'  => 'rArr',
            '->'  => 'rarr'
        }

        def inline_arrows(text)
            WIKING_ARROWS.sort{ |a, b| a[1] <=> b[1] }.each do |code, entity|
                text.gsub!(%r{#{code}}m) do |match|
                    "&#{entity};"
                end
            end
        end

    end

end
