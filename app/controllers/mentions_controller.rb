class MentionsController < ApplicationController
    include ApplicationHelper

    before_filter :find_user

    def index # FIXME what about visible?
        mentions = Mention.find(:all, # FIXME check for user
                                :order => "created_on DESC",
                                :limit => 50) # FIXME no limit?
        @mentions_by_day = mentions.group_by do |mention|
            mention.created_on.to_date
        end
    end

private

    # A copy of #find_user in UsersController
    def find_user
        if params[:id] == 'current'
            require_login || return
            @user = User.current
        else
            @user = User.find(params[:id])
        end
    rescue ActiveRecord::RecordNotFound
        render_404
    end

end
