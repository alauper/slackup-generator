# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

class SlackUp
  AUTHOR_NAME         = "YOUR-NAME"
  AUTHORIZATION_TOKEN = "YOUR-GITHUB-API-AUTH-TOKEN"
  GITHUB_API_BASE     = "https://api.github.com/repos/acima-credit/merchant_portal/pulls"
  GITHUB_WEB_BASE     = "https://github.com/acima-credit/merchant_portal/pull"
  JIRA_BASE           = "https://jira.smpl.ch/browse"
  JIRA_ID_REGEX       = /Ticket.*jira.smpl.ch\/browse\/([\w-]+).*## Description/m
  SLACK_WEB_HOOK      = "https://hooks.slack.com/services/YOUR-SLACK-WEBHOOK"

  def self.run
    prompt_for_input
    format_output
    confirm_post
  end

  def self.prompt_for_input
    print "PR ID: "
    @pr_id = gets.chomp

    print "Deploy: "
    @deploy_message = gets.chomp

    print "Update: "
    @update_message = gets.chomp
  end

  def self.format_output
    url = "#{GITHUB_API_BASE}/#{@pr_id}"
    uri = URI(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new uri
    request["Authorization"] = "token #{AUTHORIZATION_TOKEN}"
    request["content-type"] = "application/json"
    response = http.request(request)
    parsed_response = JSON.parse(response.body)

    title = parsed_response['title']
    body = parsed_response['body']

    jira_id = body[JIRA_ID_REGEX, 1]

    @slackup_post = <<~END
      *Ticket*:  #{JIRA_BASE}/#{jira_id}
      *PR*:      #{GITHUB_WEB_BASE}/#{@pr_id}
      *Title*:   #{title}
      *Deploy*:  #{@deploy_message}
      *Update*:  #{@update_message}
    END
  end

  def self.confirm_post
    puts "\n----\n"
    puts @slackup_post
    print "Would you like to post to slack? (y/n): "

    response = gets.chomp

    if response.downcase == "y"
      uri = URI.parse(SLACK_WEB_HOOK)
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"

      request.body = JSON.dump(
        text: "#{AUTHOR_NAME}\n#{@slackup_post}"
      )

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    elsif response.downcase == "n"
      puts "Aborted"
    else
      puts "Invalid entry aborted."
    end
  end
end

SlackUp.run
