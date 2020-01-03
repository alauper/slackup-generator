# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

class SlackUp
  AUTHOR_NAME         = "YOUR-NAME"
  AUTHORIZATION_TOKEN = "YOUR-GITHUB-API-AUTH-TOKEN"
  GITHUB_API_BASE     = "https://api.github.com/repos/acima-credit/merchant_portal/pulls"
  GITHUB_WEB_BASE     = "https://github.com/acima-credit/merchant_portal/pull"
  INCLUDE_IMAGES      = true
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
      Ticket:  #{JIRA_BASE}/#{jira_id}
      PR:      #{GITHUB_WEB_BASE}/#{@pr_id}
      Title:   #{title}
      Deploy:  #{@deploy_message}
      Update:  #{@update_message}
    END
  end

  def self.confirm_post
    puts "\n----\n"
    puts @slackup_post
    print "Would you like to post to slack? (y/n): "

    response = gets.chomp

    if response.downcase == "y"
      image = image_list.sample
      uri = URI.parse(SLACK_WEB_HOOK)
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"

      if INCLUDE_IMAGES
        request.body = JSON.dump(
          "attachments": [
            {
              author_name: AUTHOR_NAME,
              text: @slackup_post,
              thumb_url: image,
            }
          ],
        )
      else
        request.body = JSON.dump(
          text: "#{AUTHOR_NAME}\n#{@slackup_post}"
        )
      end

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

  def self.image_list
    %w(
      https://drive.google.com/uc?export=download&id=1jVJAmBSHsyM92PvfkDj28fZ_bWdxiPBD
      https://drive.google.com/uc?export=download&id=1er6ertfIK4WEyrC5RzEKrHjda1Nm0ige
      https://drive.google.com/uc?export=download&id=1PQBaKEmVJs_XmY6EbbGa_JG8qB8QojqX
      https://drive.google.com/uc?export=download&id=1tuLL3fFH4X7spmgvmqc2dIBl73SX5AYI
      https://drive.google.com/uc?export=download&id=1boAUqUN5S3T3qqdv5-38FRmHULwYHsG2
      https://drive.google.com/uc?export=download&id=1bTJR0JMWhA5pQ0NUjDUj7QX3xLwJ4lUU
      https://drive.google.com/uc?export=download&id=14aonTqq1Q0sSFOILhbomqh9i98DJOUiI
      https://drive.google.com/uc?export=download&id=14aonTqq1Q0sSFOILhbomqh9i98DJOUiI
      https://drive.google.com/uc?export=download&id=1YL-FNAGbmM3x8UedtZIjhTGbVG-J53em
      https://drive.google.com/uc?export=download&id=1AWTPpqpBD830LQlb5YE9eciffKUR-cVx
      https://drive.google.com/uc?export=download&id=1-Kf7Pi_B6_HgA1gML5BfMcb1FRMkzE6w
      https://drive.google.com/uc?export=download&id=1qsR0MaP-Etbgz9lhKY88NhGBuGcBoZyR
      https://drive.google.com/uc?export=download&id=1fOU_lpyICUGZGrcxQ5Vg7-P4MTAbqZpj
      https://drive.google.com/uc?export=download&id=1K5vBL2FGOOMNg8kDvCAyTvWrwRN7mQ-s
      https://drive.google.com/uc?export=download&id=1i6SpWCZDMRWn_R6_MNXgXUpaihPi7RCn
      https://drive.google.com/uc?export=download&id=1TJkLgmCzDk9JvtGYPsT1eJuZY_M5GpL8
      https://drive.google.com/uc?export=download&id=16R15uVM7id7fz68dII228Z7uA2Nq8x46
      https://drive.google.com/uc?export=download&id=1dQ-tQIdAso1vyqyhFfPaFGTSqdQ2ZKuZ
      https://drive.google.com/uc?export=download&id=14ZEzPDblLxA6dIEGjxJ1UbMeD3AZfyqX
      https://drive.google.com/uc?export=download&id=1qWWyoDwOJZi96rOz5RsXrSlYyDnfoxZC
      https://drive.google.com/uc?export=download&id=1ADUdP8UBYjPAYNUo3R5UVjQQM6dCS0J1
      https://drive.google.com/uc?export=download&id=1XBcOUV-pjZkP92a2cxh86WR4y2yYQJ-K
      https://drive.google.com/uc?export=download&id=1YtGst7n4RUkGHnGuU7DI9EeFJly4KAnF
      https://drive.google.com/uc?export=download&id=1pyW1cDXHP6OIPiSdEC4qwXo_7m7YqQpz
      https://drive.google.com/uc?export=download&id=1-rkkOuhw6vX30EOvihazMG4E5zW0h1ba
      https://drive.google.com/uc?export=download&id=1b6K6oXv-FSog1u0387mVW3BJZoqwe24f
      https://drive.google.com/uc?export=download&id=1jXQfBPSrtFYqg4XEeu-TQF77bawpbjh2
      https://drive.google.com/uc?export=download&id=1Hx26AKgGO8MQfLHyiTcssZi-lEYc_u6L
      https://drive.google.com/uc?export=download&id=1Kr64_vIOkkl7oq5x2VQBnXnC1XqYYBjm
      https://drive.google.com/uc?export=download&id=1HHS2sQjioLLEr4j0iWbTLhnzYETAW1cK
      https://drive.google.com/uc?export=download&id=1E5pKrpc1ky_urrnuSYdegA0W0yAjsKfr
      https://drive.google.com/uc?export=download&id=10H7tk6In2eC-sTV5mDGtf1DSg4II9OX4
      https://drive.google.com/uc?export=download&id=1eO0OPgdBXnGYseZg_n6TQl327GbrNLUS
      https://drive.google.com/uc?export=download&id=10baeSbfnn4wOb2RCt3mTGIwqpBYusC-V
      https://drive.google.com/uc?export=download&id=1hVsAdLgGTbH3YfJY36LqmUuO9cVxcuoB
      https://drive.google.com/uc?export=download&id=1qNFwnNU-jaa4HQ1RS6rYFgqxjHZs98HD
      https://drive.google.com/uc?export=download&id=1mAtncpafPg8LCo9RVzZszfer_19ca_hj
      https://drive.google.com/uc?export=download&id=1_YelTicK3Q6eQXA_UhVILKBtpORbgjtt
      https://drive.google.com/uc?export=download&id=1OxNzmfrf6CiJClT0wcaFZFGLGoMALRWt
      https://drive.google.com/uc?export=download&id=15URic_oAU-o2iSD8tAzVAzXWNp1-c-jL
      https://drive.google.com/uc?export=download&id=18kh69DyCKEACBPqtnfzHYHdUT2YWv7fe
      https://drive.google.com/uc?export=download&id=1u81x8DqE7x8xluHspTxklTArsKxNbq_T
      https://drive.google.com/uc?export=download&id=1AjuOGvXmeIZapyZgDXTkdNqGM0tXsw9k
    )
  end
end

SlackUp.run
