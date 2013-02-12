if defined? HipChat
  class NotificationServices::HipchatService < NotificationService
    Label = 'hipchat'
    Fields = [
      [:api_token, {
        :placeholder => "API Token"
      }],
      [:room_id, {
        :placeholder => "Room name",
        :label       => "Room name"
      }],
    ]

    def check_params
      if Fields.any? { |f, _| self[f].blank? }
        errors.add :base, 'You must specify your Hipchat API token and Room ID'
      end
    end

    def url
      "https://www.hipchat.com/sign_in"
    end

    def create_notification(problem)
      url = app_problem_url problem.app, problem

      problem = case problem.environment
        when 'production'
          %Q{<img src="http://i.imgur.com/6vJSiuc.png" alt="production">}
        when 'staging'
          %Q{<img src="http://i.imgur.com/NgyaN7V.png" alt="staging">}
        else
          "[#{problem.environment}]"
      end

      message = %Q{#{problem} <b>#{ERB::Util.html_escape problem.app.name}</b> <i>#{problem.where}</i><br/><a href="#{url}">#{problem.message.to_s.truncate 100}</a>}

      client = HipChat::Client.new(api_token)
      client[room_id].send('Errbit', message, :color => 'red')
    end
  end
end
