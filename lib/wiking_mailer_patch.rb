require_dependency 'mailer'

module WikingMailerPatch

    def self.included(base)
        if Rails::VERSION::MAJOR < 3
            base.send(:include, Rails2InstanceMethods)
        else
            base.send(:include, InstanceMethods)
        end
        base.class_eval do
            unloadable
        end
    end

    module InstanceMethods

        # TODO

    end

    module Rails2InstanceMethods

        def mention(mention)
            subject_prefix = mention.project ? "[#{mention.project.name}] " : ''

            redmine_headers('Mentioning-Type' => mention.mentioning.class.name,
                            'Mentioning-Id'   => mention.mentioning.id)
            redmine_headers('Project'         => mention.project.identifier) if mention.project
            message_id(mention)
            recipients(mention.mentioned.mail) # FIXME array?
            subject(subject_prefix + l(:mail_subject_you_mentioned, :locale =>  mention.mentioned.language))
            body(:title => mention.title,
                 :url   => mention.url,
                 :user  => mention.mentioned)

            render_multipart('you_mentioned', body)
        end

    end

end
