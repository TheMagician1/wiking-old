class MentionObserver < ActiveRecord::Observer

    def after_create(mention)
        if Setting.notified_events.include?('user_mentioned') &&
           %w(all only_my_events only_owner).include?(mention.mentioned.mail_notification) &&
           mention.title.present? && mention.url.present? && mention.created_on < 1.day.ago &&
           (!mention.mentioning.respond_to?(:visible?) || mention.mentioning.visible?(mention.mentioned))
            Mailer.deliver_mention(mention)
        end
    end

end
