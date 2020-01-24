# Slackup-generator

1. Clone this repo
There are two versions of the template - one with images, one without.
`template_with_images.rb`
`tempalte.rb`


2. All configuration settings are at the top of the file.
Change `AUTHOR_NAME`, `AUTHORIZATION_TOKEN`, `SLACK_WEB_HOOK`
```
AUTHOR_NAME         = "YOUR-NAME"
AUTHORIZATION_TOKEN = "YOUR-GITHUB-API-AUTH-TOKEN"
...
SLACK_WEB_HOOK      = "https://hooks.slack.com/services/YOUR-SLACK-WEBHOOK"
```

3. If you're using the `template_with_images.rb`, you'll need to include links to your preferred images at the bottom.

4. Run from anywhere with an alias. This step depends on which file you want to run.
`echo "alias slackup='ruby path/to/template.rb'" >> ~/.bash_profile`
or
`echo "alias slackup='ruby path/to/template_with_images.rb'" >> ~/.bash_profile`

The output will look similar to
```
PR ID:
Deploy:
Update:

----
*Ticket*:  https://jira.smpl.ch/browse/ATL-XXXX
*PR*:      https://github.com/acima-credit/merchant_portal/pull/XXXX
*Title*:   [Title Pulled From PR]
*Deploy*:  [Today]
*Update*:  [This is my update]
Would you like to post to slack? (y/n):
```
